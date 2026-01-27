// Zekr__Colors - ANSI color utilities for console output

let reset = "\x1b[0m"
let green = "\x1b[32m"
let red = "\x1b[31m"
let yellow = "\x1b[33m"
let cyan = "\x1b[36m"
let dim = "\x1b[2m"
let bold = "\x1b[1m"

let pass = text => `${green}${text}${reset}`
let fail = text => `${red}${text}${reset}`
let skip = text => `${yellow}${text}${reset}`
let suite = text => `${cyan}${bold}${text}${reset}`
let dimmed = text => `${dim}${text}${reset}`
