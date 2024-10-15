local vim = vim -- Prevents undefined vim if overridden somewhere else

local M = {}

function M.get_bufnr(bufnr)
    return type(bufnr) == 'number' and bufnr or vim.api.nvim_get_current_buf()
end

function M.get_current_path(bufnr)
    return vim.api.nvim_buf_get_name(M.get_bufnr(bufnr))
end

function M.root_dir_from_pattern(bufnr, pattern)
    local root_dir = vim.fs.root(M.get_bufnr(bufnr), pattern)
    return root_dir or vim.loop.cwd()
end

function M.yarn_lock_root_dir(bufnr)
    return M.root_dir_from_pattern(bufnr, 'yarn.lock')
end

function M.tsconfig_root_dir(bufnr)
    return M.root_dir_from_pattern(bufnr, 'tsconfig.json')
end

function M.get_file_metadata(bufnr)
    local package_json = 'package.json'
    local path = M.get_current_path(bufnr)

    local metadata = {
        relative_path = path,
        package_name = nil,
    }

    local package_root = vim.fs.root(bufnr, package_json)

    if package_root then
        local package_info = io.open(package_root .. '/' .. package_json):read('*a')
        metadata['package_name'] = vim.json.decode(package_info).name or 'Unknown package'

        -- Since `package_root` is not a regex, make it a pattern first
        -- See https://www.gammon.com.au/scripts/doc.php?lua=string.gsub
        local package_root_pattern = string.gsub(package_root .. '/', "[%%%]%^%-$().[*+?]", "%%%1")
        metadata['relative_path'] = string.gsub(path, package_root_pattern, '')
    end

    return metadata
end

return M
