# TODO

## Next (1.0.0)

- CMD+click (opens a new tab with the URL)
- Support opening of `target="_blank"` links in a new tab
- Right click menu for right-clicking a link
- Support downloads
- Cut/Copy/Paste/Select-All keyboard shortcuts within websites (e.g. in form text fields) 
- Switch to using c_tab_folder/c_tab_item
- Use Nebula FontAwesome for Back/Forward buttons
- CMD+F (find dialog)
- CMD+1..9 shortcuts for jumping to tabs
- Remember last open tabs
- History
- connector-setup (to work across Rubies in RVM)
- Have the engine option menu items switch the engine in the current tab (by disposing and recreating)
- Show favicon on every tab
- Change Home Page
- CMD+ENTER (ALT+ENTER) Address Bar opens same address in new tab
- Reorder tabs
- When closing the last tab in a window, close the window
- When opening a new window, ensure it uses the default engine
- Explore the [jxbrowser](https://www.teamdev.com/jxbrowser) third-party SWT custom widget, which supports a much newer version of Chromium (version 84 today)
- Turn this app into a reusable custom shell, embeddable in other apps as a nested browser window.
- Support Windows with Chromium and IE
- Support Linux with Chromium and WebKitGTK (where available as per the [SWT FAQ](https://www.eclipse.org/swt/faq.php#browserwebkitgtk))

## Issues

- Prevent double select-all when adding a new tab and starting to type in the address bar
- Upside down text showing up on rare occasions (might just be due to old chromium/webkit engines)
- Window jitter when rendering some websites in Chromium (might be related to packing of tab or chromium engine being old)
- Non-immediate update of address bar when opening a website (there is a slight delay caused perhaps due to relying on title events instead of location events) 
