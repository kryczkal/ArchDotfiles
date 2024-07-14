-- Description: Colorize color codes in your file
return {
    {
        'norcalli/nvim-colorizer.lua',
        config = function()
            require('colorizer').setup()
        end
    },
}
