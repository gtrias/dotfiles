local status, projectconfig = pcall(require, "nvim-projectconfig")
if not status then
  return
end

projectconfig.setup({
  project_dir = "~/.config/nvim/lua/projects",
  project_config={
    {
      path = "/home/genar/src/factorial/backend",
      config = "~/.config/nvim/lua/projects/factorial-backend.lua"
    },
    {
      path = "/home/genar/src/factorial/frontend",
      config = "~/.config/nvim/lua/projects/factorial-frontend.lua"
    },
    {
      path = ".*", -- Catch all, default config
      config = "~/.config/nvim/lua/projects/default.lua"
    },
  },
})
