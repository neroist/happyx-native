import
  std/strutils,
  std/os,
  std/osproc,
  ../exceptions,
  ../constants

const profileDir = getHomeDir() / ".happyx-native" / "firefox-profile"

when OS == "mac":
  import std/sequtils

  proc findMac: string =
    try:
      for path in FirefoxPaths:
        if path.absolutePath.fileExists:
          return path
      let alternateDirs = execProcess(
        "mdfind",
        args = ["Firefox.app"],
        options = {poUsePath}
      ).split("\n")
      alternateDirs.keepItIf(it.contains("Firefox.app"))
      if alternateDirs.len > 0:
        return alternateDirs[0] & "/Contents/MacOS"
      raise newException(FirefoxNotFound, "could not find Firefox using `mdfind`")
    except:
      raise newException(FirefoxNotFound, "could not find Firefox in Applications directory")
elif OS == "win":
  import std/registry

  proc findWindows: string =
    for path in FirefoxPaths:
      if path.absolutePath.fileExists:
        return path
    result = getUnicodeValue(
      path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe",
      key = "", handle = HKEY_LOCAL_MACHINE
    )
    if result.len == 0:
      raise newException(FirefoxNotFound, "could not find Firefox")
elif OS == "unix":
  proc findLinux: string =
    for name in FirefoxPaths:
      if execCmd("which " & name) == 0:
        return name
    raise newException(FirefoxNotFound, "could not find Firefox")


proc findPath: string =
  when OS == "mac":
    result = findMac()
  elif OS == "win":
    result = findWindows()
  elif OS == "unix":
    result = findLinux()
  else:
    raise newException(FirefoxNotFound, "unsupported OS")


proc createProfile*(path: string, profileName: string) =
  if dirExists(profileDir):
    return

  createDir(profileDir)

  if execCmd("$1 -CreateProfile \"$2 $3\"" % [path, profileName, profileDir]) != 0:
    raise newException(FirefoxNotFound, "could not create Firefox profile")

  # Wait for Firefox profile to be created
  sleep 2000
  
  writeFile(profileDir / "user.js"): 
    dedent """
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
    user_pref("browser.tabs.warnOnClose", false);
    user_pref("browser.tabs.inTitlebar", 2);
    """
  
  createDir(profileDir / "chrome")
  writeFile(profileDir / "chrome" / "userChrome.css"):
    """:root{--uc-toolbar-height:32px}:root:not([uidensity="compact"]) {--uc-toolbar-height:38px}#TabsToolbar{visibility:collapse!important}:root:not([inFullscreen]) #nav-bar{margin-top:calc(0px - var(--uc-toolbar-height))}#toolbar-menubar{min-height:unset!important;height:var(--uc-toolbar-height)!important;position:relative}#main-menubar{-moz-box-flex:1;background-color:var(--toolbar-bgcolor,--toolbar-non-lwt-bgcolor);background-clip:padding-box;border-right:30px solid transparent;border-image:linear-gradient(to left,transparent,var(--toolbar-bgcolor,--toolbar-non-lwt-bgcolor) 30px) 20 / 30px}#toolbar-menubar:not([inactive]) {z-index:2}#toolbar-menubar[inactive] > #menubar-items{opacity:0;pointer-events:none;margin-left:var(--uc-window-drag-space-width,0px)}#nav-bar{visibility:collapse}@-moz-document url(chrome://browser/content/browser.xhtml) {:root:not([sizemode="fullscreen"]) > head{display: block;position: fixed;width: calc(200vw - 440px);text-align: left;z-index: 9;pointer-events: none;}head > *{ display: none }head > title{display: -moz-inline-box;padding: 4px;max-width: 50vw;overflow-x: hidden;text-overflow: ellipsis;}}"""
    # """#navigator-toolbox{opacity:0 !important; height:0px !important; max-height:0px !important; width:0px !important; max-width:0px !important;}"""

proc openFirefox*(port: int, profileName: string, firefoxFlags: openarray[string]) =
  let path = findPath()
  createProfile(path, profileName)
  var command = " -P $1 -purgecaches -new-window http://localhost:$2" % [profileName, $port]
  for flag in firefoxFlags:
    command = command & " " & flag.strip
  if execCmd(path & command) != 0:
    raise newException(FirefoxNotFound, "could not open Firefox browser")
