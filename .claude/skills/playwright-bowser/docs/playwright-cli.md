# Playwright CLI Reference

## Installation

```bash
npm install -g @playwright/cli@latest
playwright-cli --help
```

## Core Commands

```
playwright-cli open [url]               # open browser, optionally navigate to url
playwright-cli goto <url>               # navigate to a url
playwright-cli close                    # close the page
playwright-cli type <text>              # type text into editable element
playwright-cli click <ref> [button]     # perform click on a web page
playwright-cli dblclick <ref> [button]  # perform double click on a web page
playwright-cli fill <ref> <text>        # fill text into editable element
playwright-cli drag <startRef> <endRef> # perform drag and drop between two elements
playwright-cli hover <ref>              # hover over element on page
playwright-cli select <ref> <val>       # select an option in a dropdown
playwright-cli upload <file>            # upload one or multiple files
playwright-cli check <ref>              # check a checkbox or radio button
playwright-cli uncheck <ref>            # uncheck a checkbox or radio button
playwright-cli snapshot                 # capture page snapshot to obtain element ref
playwright-cli snapshot --filename=f    # save snapshot to specific file
playwright-cli eval <func> [ref]        # evaluate javascript expression on page or element
playwright-cli dialog-accept [prompt]   # accept a dialog
playwright-cli dialog-dismiss           # dismiss a dialog
playwright-cli resize <w> <h>           # resize the browser window
```

## Navigation

```
playwright-cli go-back                  # go back to the previous page
playwright-cli go-forward               # go forward to the next page
playwright-cli reload                   # reload the current page
```

## Keyboard

```
playwright-cli press <key>              # press a key on the keyboard, `a`, `arrowleft`
playwright-cli keydown <key>            # press a key down on the keyboard
playwright-cli keyup <key>              # press a key up on the keyboard
```

## Mouse

```
playwright-cli mousemove <x> <y>        # move mouse to a given position
playwright-cli mousedown [button]       # press mouse down
playwright-cli mouseup [button]         # press mouse up
playwright-cli mousewheel <dx> <dy>     # scroll mouse wheel
```

## Save As

```
playwright-cli screenshot [ref]         # screenshot of the current page or element
playwright-cli screenshot --filename=f  # save screenshot with specific filename
playwright-cli pdf                      # save page as pdf
playwright-cli pdf --filename=page.pdf  # save pdf with specific filename
```

## Tabs

```
playwright-cli tab-list                 # list all tabs
playwright-cli tab-new [url]            # create a new tab
playwright-cli tab-close [index]        # close a browser tab
playwright-cli tab-select <index>       # select a browser tab
```

## Storage

```
playwright-cli state-save [filename]    # save storage state
playwright-cli state-load <filename>    # load storage state

# Cookies
playwright-cli cookie-list [--domain]   # list cookies
playwright-cli cookie-get <name>        # get a cookie
playwright-cli cookie-set <name> <val>  # set a cookie
playwright-cli cookie-delete <name>     # delete a cookie
playwright-cli cookie-clear             # clear all cookies

# LocalStorage
playwright-cli localstorage-list        # list localStorage entries
playwright-cli localstorage-get <key>   # get localStorage value
playwright-cli localstorage-set <k> <v> # set localStorage value
playwright-cli localstorage-delete <k>  # delete localStorage entry
playwright-cli localstorage-clear       # clear all localStorage

# SessionStorage
playwright-cli sessionstorage-list      # list sessionStorage entries
playwright-cli sessionstorage-get <k>   # get sessionStorage value
playwright-cli sessionstorage-set <k> <v> # set sessionStorage value
playwright-cli sessionstorage-delete <k>  # delete sessionStorage entry
playwright-cli sessionstorage-clear     # clear all sessionStorage
```

## Network

```
playwright-cli route <pattern> [opts]   # mock network requests
playwright-cli route-list               # list active routes
playwright-cli unroute [pattern]        # remove route(s)
```

## DevTools

```
playwright-cli console [min-level]      # list console messages
playwright-cli network                  # list all network requests since loading the page
playwright-cli run-code <code>          # run playwright code snippet
playwright-cli tracing-start            # start trace recording
playwright-cli tracing-stop             # stop trace recording
playwright-cli video-start              # start video recording
playwright-cli video-stop [filename]    # stop video recording
```

## Sessions

```
playwright-cli -s=name <cmd>            # run command in named session
playwright-cli -s=name close            # stop a named browser
playwright-cli -s=name delete-data      # delete user data for named browser
playwright-cli list                     # list all sessions
playwright-cli close-all                # close all browsers
playwright-cli kill-all                 # forcefully kill all browser processes
```

## Configuration

```
playwright-cli config [options]         # configure session settings
playwright-cli open --browser=chrome    # use specific browser
playwright-cli open --extension         # connect via browser extension
playwright-cli open --persistent        # use persistent profile
playwright-cli open --profile=<path>    # use custom profile directory
playwright-cli open --config=file.json  # use config file
playwright-cli close                    # close the browser
playwright-cli delete-data              # delete user data for default session
```

## Configuration File

Place a `playwright-cli.json` in the working directory for automatic loading:

```json
{
  "browser": {
    "browserName": "chromium",
    "launchOptions": { "headless": true },
    "contextOptions": { "viewport": { "width": 1440, "height": 900 } }
  },
  "outputDir": "./screenshots"
}
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `PLAYWRIGHT_MCP_VIEWPORT_SIZE` | Browser viewport size, e.g. "1440x900" |
| `PLAYWRIGHT_MCP_CAPS` | Additional capabilities: "vision", "pdf" |
| `PLAYWRIGHT_MCP_BROWSER` | Browser to use: chrome, firefox, webkit, msedge |
| `PLAYWRIGHT_MCP_HEADLESS` | Run in headless mode |
| `PLAYWRIGHT_MCP_OUTPUT_DIR` | Directory for output files |
| `PLAYWRIGHT_MCP_CONFIG` | Path to config file |
| `PLAYWRIGHT_MCP_TIMEOUT_ACTION` | Action timeout in ms (default 5000) |
| `PLAYWRIGHT_MCP_TIMEOUT_NAVIGATION` | Navigation timeout in ms (default 60000) |
