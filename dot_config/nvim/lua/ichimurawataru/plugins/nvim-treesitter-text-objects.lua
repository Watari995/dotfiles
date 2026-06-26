return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    local select = require("nvim-treesitter-textobjects.select")
    local swap = require("nvim-treesitter-textobjects.swap")
    local move = require("nvim-treesitter-textobjects.move")
    local repeatable_move = require("nvim-treesitter-textobjects.repeatable_move")

    -- ── Select ───────────────────────────────────────────────────────────
    local function sel(query)
      return function()
        select.select_textobject(query, "textobjects")
      end
    end

    vim.keymap.set({ "x", "o" }, "a=", sel("@assignment.outer"), { desc = "outer assignment" })
    vim.keymap.set({ "x", "o" }, "i=", sel("@assignment.inner"), { desc = "inner assignment" })
    vim.keymap.set({ "x", "o" }, "l=", sel("@assignment.lhs"), { desc = "lhs of assignment" })
    vim.keymap.set({ "x", "o" }, "r=", sel("@assignment.rhs"), { desc = "rhs of assignment" })

    vim.keymap.set({ "x", "o" }, "a:", sel("@property.outer"), { desc = "outer object property" })
    vim.keymap.set({ "x", "o" }, "i:", sel("@property.inner"), { desc = "inner object property" })
    vim.keymap.set({ "x", "o" }, "l:", sel("@property.lhs"), { desc = "lhs of object property" })
    vim.keymap.set({ "x", "o" }, "r:", sel("@property.rhs"), { desc = "rhs of object property" })

    vim.keymap.set({ "x", "o" }, "aa", sel("@parameter.outer"), { desc = "outer parameter" })
    vim.keymap.set({ "x", "o" }, "ia", sel("@parameter.inner"), { desc = "inner parameter" })

    vim.keymap.set({ "x", "o" }, "ai", sel("@conditional.outer"), { desc = "outer conditional" })
    vim.keymap.set({ "x", "o" }, "ii", sel("@conditional.inner"), { desc = "inner conditional" })

    vim.keymap.set({ "x", "o" }, "al", sel("@loop.outer"), { desc = "outer loop" })
    vim.keymap.set({ "x", "o" }, "il", sel("@loop.inner"), { desc = "inner loop" })

    vim.keymap.set({ "x", "o" }, "af", sel("@call.outer"), { desc = "outer function call" })
    vim.keymap.set({ "x", "o" }, "if", sel("@call.inner"), { desc = "inner function call" })

    vim.keymap.set({ "x", "o" }, "am", sel("@function.outer"), { desc = "outer method/function def" })
    vim.keymap.set({ "x", "o" }, "im", sel("@function.inner"), { desc = "inner method/function def" })

    vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer"), { desc = "outer class" })
    vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner"), { desc = "inner class" })

    -- ── Swap ─────────────────────────────────────────────────────────────
    vim.keymap.set("n", "<leader>na", function()
      swap.swap_next("@parameter.inner", "textobjects")
    end, { desc = "Swap parameter with next" })
    vim.keymap.set("n", "<leader>pa", function()
      swap.swap_previous("@parameter.inner", "textobjects")
    end, { desc = "Swap parameter with prev" })
    vim.keymap.set("n", "<leader>nm", function()
      swap.swap_next("@function.outer", "textobjects")
    end, { desc = "Swap function with next" })
    vim.keymap.set("n", "<leader>pm", function()
      swap.swap_previous("@function.outer", "textobjects")
    end, { desc = "Swap function with prev" })
    vim.keymap.set("n", "<leader>n:", function()
      swap.swap_next("@property.outer", "textobjects")
    end, { desc = "Swap property with next" })
    vim.keymap.set("n", "<leader>p:", function()
      swap.swap_previous("@property.outer", "textobjects")
    end, { desc = "Swap property with prev" })

    -- ── Move (repeatable with ; and ,) ───────────────────────────────────
    local function mk(fn)
      return repeatable_move.make_repeatable_move(fn)
    end

    vim.keymap.set({ "n", "x", "o" }, "]f", mk(function()
      move.goto_next_start("@call.outer", "textobjects")
    end), { desc = "Next function call start" })
    vim.keymap.set({ "n", "x", "o" }, "]m", mk(function()
      move.goto_next_start("@function.outer", "textobjects")
    end), { desc = "Next method/func def start" })
    vim.keymap.set({ "n", "x", "o" }, "]c", mk(function()
      move.goto_next_start("@class.outer", "textobjects")
    end), { desc = "Next class start" })
    vim.keymap.set({ "n", "x", "o" }, "]i", mk(function()
      move.goto_next_start("@conditional.outer", "textobjects")
    end), { desc = "Next conditional start" })
    vim.keymap.set({ "n", "x", "o" }, "]l", mk(function()
      move.goto_next_start("@loop.outer", "textobjects")
    end), { desc = "Next loop start" })

    vim.keymap.set({ "n", "x", "o" }, "]F", mk(function()
      move.goto_next_end("@call.outer", "textobjects")
    end), { desc = "Next function call end" })
    vim.keymap.set({ "n", "x", "o" }, "]M", mk(function()
      move.goto_next_end("@function.outer", "textobjects")
    end), { desc = "Next method/func def end" })
    vim.keymap.set({ "n", "x", "o" }, "]C", mk(function()
      move.goto_next_end("@class.outer", "textobjects")
    end), { desc = "Next class end" })
    vim.keymap.set({ "n", "x", "o" }, "]I", mk(function()
      move.goto_next_end("@conditional.outer", "textobjects")
    end), { desc = "Next conditional end" })
    vim.keymap.set({ "n", "x", "o" }, "]L", mk(function()
      move.goto_next_end("@loop.outer", "textobjects")
    end), { desc = "Next loop end" })

    vim.keymap.set({ "n", "x", "o" }, "[f", mk(function()
      move.goto_previous_start("@call.outer", "textobjects")
    end), { desc = "Prev function call start" })
    vim.keymap.set({ "n", "x", "o" }, "[m", mk(function()
      move.goto_previous_start("@function.outer", "textobjects")
    end), { desc = "Prev method/func def start" })
    vim.keymap.set({ "n", "x", "o" }, "[c", mk(function()
      move.goto_previous_start("@class.outer", "textobjects")
    end), { desc = "Prev class start" })
    vim.keymap.set({ "n", "x", "o" }, "[i", mk(function()
      move.goto_previous_start("@conditional.outer", "textobjects")
    end), { desc = "Prev conditional start" })
    vim.keymap.set({ "n", "x", "o" }, "[l", mk(function()
      move.goto_previous_start("@loop.outer", "textobjects")
    end), { desc = "Prev loop start" })

    vim.keymap.set({ "n", "x", "o" }, "[F", mk(function()
      move.goto_previous_end("@call.outer", "textobjects")
    end), { desc = "Prev function call end" })
    vim.keymap.set({ "n", "x", "o" }, "[M", mk(function()
      move.goto_previous_end("@function.outer", "textobjects")
    end), { desc = "Prev method/func def end" })
    vim.keymap.set({ "n", "x", "o" }, "[C", mk(function()
      move.goto_previous_end("@class.outer", "textobjects")
    end), { desc = "Prev class end" })
    vim.keymap.set({ "n", "x", "o" }, "[I", mk(function()
      move.goto_previous_end("@conditional.outer", "textobjects")
    end), { desc = "Prev conditional end" })
    vim.keymap.set({ "n", "x", "o" }, "[L", mk(function()
      move.goto_previous_end("@loop.outer", "textobjects")
    end), { desc = "Prev loop end" })

    -- ── Repeatable f / F / t / T ─────────────────────────────────────────
    vim.keymap.set({ "n", "x", "o" }, ";", repeatable_move.repeat_last_move)
    vim.keymap.set({ "n", "x", "o" }, ",", repeatable_move.repeat_last_move_opposite)
    vim.keymap.set({ "n", "x", "o" }, "f", repeatable_move.builtin_f_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "F", repeatable_move.builtin_F_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "t", repeatable_move.builtin_t_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "T", repeatable_move.builtin_T_expr, { expr = true })
  end,
}
