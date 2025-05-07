---@meta

---@class zeekay.Config.Notes The configuration for notes
---@field dir string The directory to put notes in
---@field id_func function The function to call for getting the ID of a note
---@field frontmatter_func function The function to call for getting the frontmatter of a note

---@class zeekay.Config The config for zeekay.nvim
---@field notes zeekay.Config.Notes The notes directory to use
