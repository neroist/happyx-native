## # HappyX Native 🔥
## 
## .. Note::
##    HappyX web framework, but for native platforms
## 
## ## API Reference 📕
## 
## ### Core ⚙
## - [exceptions](happyx_native/core/exceptions.html) - list of all exceptions
## - [constants](happyx_native/core/constants.html) - list of constants
## - #### **f i n d e r**
##   .. Note::
##      provides some browsers finders
##   - [chrome](happyx_native/core/finder/chrome.html) - Chrome browser finder (this browser choosen by default)
##   - [edge](happyx_native/core/finder/edge.html) - Edge browser finder (compile with `-d:edge` to enable this browser)
##   - [yandex](happyx_native/core/finder/yandex.html) - Yandex browser finder <sup> (compile with `-d:yandex` to enable this browser)
##   - [firefox](happyx_native/core/finder/firefox.html) - Firefox browser finder <sup> (compile with `-d:firefox` to enable this browser) </sup>
## ### App 🎴
## - [app](happyx_native/app/app.html) - provides working with native application
## 

import
  happyx_native/core/[
    constants,
    exceptions
  ],
  happyx_native/app/app

when not defined(docgen):
  when defined(yandex):
    import happyx_native/core/finder/yandex
    export yandex
  elif defined(edge):
    import happyx_native/core/finder/edge
    export edge
  elif defined(chrome):
    import happyx_native/core/finder/chrome
    export chrome
  elif defined(firefox):
    import happyx_native/core/finder/firefox
    export firefox
  else:
    import happyx_native/core/finder/default
    export default
else:
  import happyx_native/core/finder/[chrome, yandex, edge, firefox, default]
  export chrome, yandex, edge, firefox, default

when defined(export2android):
  import happyx_native/android/[core, autils]
  export core, autils

export
  constants,
  exceptions,
  app


import
  happyx_native/abstract/[saving]

export
  saving
