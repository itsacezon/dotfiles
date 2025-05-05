local vim = vim -- Prevents undefined vim if overridden somewhere else

local M = {}

---@param bufnr integer | nil
---@return integer
function M.get_bufnr(bufnr)
    return type(bufnr) == 'number' and bufnr or vim.api.nvim_get_current_buf()
end

---@param bufnr integer | nil
---@return string
function M.get_current_path(bufnr)
    return vim.api.nvim_buf_get_name(M.get_bufnr(bufnr))
end

---@param bufnr integer | nil
---@param patterns string[]
---@param fallback string?
---@return string | nil
function M.root_dir_from_pattern(bufnr, patterns, fallback)
    local root_dir = fallback or vim.loop.cwd()

    for _, pattern in pairs(patterns) do
        local found_root_dir = vim.fs.root(M.get_bufnr(bufnr), pattern)

        if found_root_dir then
            root_dir = found_root_dir
            break
        end
    end

    return root_dir
end

---@param bufnr integer | nil
---@return string | nil
function M.root_dir(bufnr)
    -- Opinionated priorities
    return M.root_dir_from_pattern(bufnr, {
        'yarn.lock',
        'tsconfig.json',
        'package.json',
        '.git',
    })
end

---@param bufnr integer | nil
function M.get_file_metadata(bufnr)
    local package_json = 'package.json'
    local cur_bufnr = M.get_bufnr(bufnr)
    local path = M.get_current_path(cur_bufnr)

    local metadata = {
        relative_path = path,
        package_name = nil,
    }

    local package_root = vim.fs.root(cur_bufnr, package_json)

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
