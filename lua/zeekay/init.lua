local M = {}

---@type zeekay.Config
M.settings = {
    notes = {
        dir = vim.fn.expand("~") .. "/notes/",
        id_func = function()
            return os.date("%d%m%Y%H%M%S") .. "-"
        end,
        ---@param name string The name of the new note
        ---@return table<string, any>
        ---@diagnostic disable-next-line: unused-local name
        frontmatter_func = function(name)
            return {
                date = os.date("%Y-%m-%d %H:%M:%S"),
                tags = "",
            }
        end,
    },
}

---Ensure notes directory exists
local function ensure_notes_dir()
    local ok = pcall(vim.fn.mkdir, M.settings.notes.dir, "p")
    if not ok then
        vim.notify("Failed to create notes directory", vim.log.levels.ERROR)
    end
end

---Slugify a string
---@param str string
---@return string slugified The slugified string
local function slugify(str)
    ---@diagnostic disable-next-line: redundant-return-value
    return str
        :lower()
        :gsub("[^a-z0-9%s-]", "") -- Remove all non-alphanumerics except space/hyphen
        :gsub("[%s-]+", "-") -- Replace space/hyphen groups with a single hyphen
        :gsub("^%-+", "") -- Trim leading hyphens
        :gsub("%-+$", "") -- Trim trailing hyphens
end

---Convert a Lua table to YAML-like frontmatter
---@param tbl table
---@return string[]
local function generate_frontmatter(tbl)
    local lines = { "---" }
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            local array_items = vim.tbl_map(function(v)
                return tostring(v)
            end, value)
            table.insert(lines, string.format("%s: [%s]", key, table.concat(array_items, ", ")))
        else
            table.insert(lines, string.format("%s: %s", key, tostring(value)))
        end
    end
    table.insert(lines, "---")
    return lines
end

---Create a new note
---@param name? string
function M.new_note(name)
    ensure_notes_dir()
    name = name or vim.fn.input("Note name: ")
    if name == "" then
        return
    end
    local filename = M.settings.notes.id_func() .. slugify(name) .. ".md"
    local full_path = M.settings.notes.dir .. filename

    local frontmatter_tbl = M.settings.notes.frontmatter_func(name)
    local frontlines = generate_frontmatter(frontmatter_tbl)

    local otherlines = {
        "",
        "# " .. name,
        "",
        "",
    }

    local lines = vim.iter({ frontlines, otherlines }):flatten():totable()

    vim.fn.writefile(lines, full_path)
    vim.cmd("edit " .. full_path)
    vim.cmd("normal! G")
end

---Pick and open a note from the notes directory
function M.pick_note()
    ensure_notes_dir()

    local files = vim.fn.globpath(M.settings.notes.dir, "*.md", false, true)
    if vim.tbl_isempty(files) then
        vim.notify("No notes found in " .. M.settings.notes.dir, vim.log.levels.INFO)
        return
    end

    local display_names = {}
    local name_map = {}

    for _, filepath in ipairs(files) do
        local filename = vim.fn.fnamemodify(filepath, ":t")
        local lines = vim.fn.readfile(filepath, "", 20)

        -- Try to find a line that starts with "# "
        local title
        for _, line in ipairs(lines) do
            if line:match("^# ") then
                title = line:sub(3)
                break
            end
        end

        -- Fall back to deslugified filename if no title found
        if not title then
            title = filename:gsub("^%d+%-", ""):gsub("%.md$", ""):gsub("-", " ")
        end

        table.insert(display_names, title)
        name_map[title] = filename
    end

    vim.ui.select(display_names, { prompt = "Select a note to open:" }, function(choice)
        if choice then
            local full_path = M.settings.notes.dir .. name_map[choice]
            vim.cmd("edit " .. vim.fn.fnameescape(full_path))
        end
    end)
end

local function setup_command()
    vim.api.nvim_create_user_command("ZeekayNewNote", function(opts)
        if opts.args == "" then
            opts.args = nil
        end
        M.new_note(opts.args)
    end, {
        nargs = "?",
        complete = function(_, _, _)
            return vim.fn.getcompletion("", "file")
        end,
        desc = "Create a new note",
    })

    vim.api.nvim_create_user_command("ZeekayPickNote", function()
        M.pick_note()
    end, {
        desc = "Pick a note to open",
    })
end

---Setup user config
---@param opts? zeekay.Config
function M.setup(opts)
    setup_command()

    M.settings = vim.tbl_deep_extend("force", M.settings, opts or {})
end

return M
