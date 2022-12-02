local M = {}

local config = {}
local ns = vim.api.nvim_create_namespace("virtual.nvim")
local icon = "■"


M.print = function(ln, content)

    local line_content = vim.api.nvim_buf_get_lines(
        0, ln, ln + 1, false
    )

    if not line_content then
        return
    end

    local col = string.len(table.concat(line_content, ''))

    vim.api.nvim_buf_set_extmark(0, ns, ln, col, {
        virt_text = M.fmt(content)
    })

end


local autocmd = function()

    -- si d'autres autocommandes sont ajoutées, elles doivent être
    -- justifiée pour des questions de légèreté (:

    vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
            local ln = vim.fn.line('.') - 1
            local content = M.get()

            M.clear()

            if #content == 0 then
                return
            end

            M.print(ln, M.get())
        end,
    })

end

M.grab = function(tograb)

    local sev = {
        ERROR = 1,
        WARN = 2,
        INFO = 3,
        HINT = 4
    }

    for _, v in ipairs(vim.tbl_keys(sev)) do

        -- la fonction grab est appellée sur les min..max sur lesquel
        -- afficher les lignes virtuel. On cherche donc à exclure ces lignes.

        local bellow = (not tograb.min or tograb.min >= sev[v])
        local up = (not tograb.max or sev[v] >= tograb.max)

        if not (bellow and up) then
            table.insert(config, sev[v])
        end
    end

    autocmd()
    return tograb
end


M.clear = function()

    local buflst = vim.tbl_filter(function(nr)
        return vim.api.nvim_buf_is_loaded(nr)
    end, vim.api.nvim_list_bufs())

    for _, bufnr in ipairs(buflst) do
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    end
end

M.get = function()
    return vim.tbl_filter(
        function(diag)
            return vim.tbl_contains(
                config,
                diag.severity
            )
        end,
        vim.diagnostic.get(
            0,
            { lnum = vim.fn.line('.') - 1 }
        ))
end


M.fmt = function(diagnostics)
    local colors = {
        "Error",
        "Warn",
        "Info",
        "Hint"
    }

    local content = {}
    local max

    for c, di in pairs(diagnostics) do

        -- je veux que le méssage soit de la couleur
        -- de la sévérité la plus élevée.

        if max == nil or di.severity > max then
            max = di.severity
        end

        -- pour chaque diagnostic, un icon de la couleur
        -- correspondant signale son existance quand même.

        table.insert(content, {
            string.rep(c == 1 and " " or "", 4) .. icon, "Diagnostic" .. colors[di.severity]
        })
    end

    table.insert(
        content,
        { " " .. diagnostics[1].message, "Diagnostic" .. colors[max] }
    )

    return content
end


return M