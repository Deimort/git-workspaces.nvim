local M = {}

M.setup = function()
    --- Plugin setup function
end

local scan = require("plenary.scandir")
local path = require("plenary.path")

local function list_folders()
    local paths = scan.scan_dir(path:new("."):absolute(), {
        only_dirs = true,
        depth = 3,
        search_pattern = function(e)
            return path:new(e, ".git"):exists()
        end,
    })
    if path:new(".", ".git"):exists() then
        table.insert(paths, path:new("."):absolute())
    end
    return require('telescope.finders').new_table({
        results = paths
    })
end

M.list_workspaces = function()
    local telescope_config = require("telescope.config").values
    local builtin = require("telescope.builtin")
    local actions = require("telescope.actions")
    local actions_state = require("telescope.actions.state")
    local neogit = require("neogit")

    require('telescope.pickers').new({},
        {
            prompt_title = "Workspaces",
            finder = list_folders(),
            previewer = telescope_config.file_previewer({}),
            sorter = telescope_config.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local entry = actions_state.get_selected_entry().value

                    neogit.open({
                        cwd = entry
                    })
                end)

                map("i", "<C-c>", function()
                    actions.close(prompt_bufnr)
                    local entry = actions_state.get_selected_entry().value
                    builtin.git_commits({
                        cwd = entry
                    })
                end)

                map("i", "<C-b>", function()
                    actions.close(prompt_bufnr)
                    local entry = actions_state.get_selected_entry().value
                    builtin.git_branches({
                        cwd = entry
                    })
                end)

                map("i", "<C-f>", function()
                    actions.close(prompt_bufnr)
                    local entry = actions_state.get_selected_entry().value
                    builtin.git_files({
                        cwd = entry
                    })
                end)

                map("i", "<C-x>", function()
                    actions.close(prompt_bufnr)
                    local entry = actions_state.get_selected_entry().value
                    builtin.git_stash({
                        cwd = entry
                    })
                end)

                return true
            end
        }
    ):find()
end

return M
