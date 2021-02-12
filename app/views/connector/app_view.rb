require 'pd'

class Connector
  class AppView
    include Glimmer::UI::CustomShell
    
    COMMAND = OS.mac? ? :command : :ctrl
    CONTROL = OS.mac? ? :ctrl : :alt
    
    ## Add options like the following to configure CustomShell by outside consumers
    #
    # options :title, :background_color
    # option :width, default: 320
    # option :height, default: 240
    # option :greeting, default: 'Hello, World!'
    
    attr_accessor :web_url

    ## Use before_body block to pre-initialize variables to use in body
    #
    #
    before_body {
      @starting = true
      @web_url = 'Enter Web Address'
      Display.app_name = 'Connector'
      Display.app_version = VERSION
      @display = display {
        on_about {
          display_about_dialog
        }
        on_preferences {
          display_about_dialog
        }
      }
    }

    ## Use after_body block to setup observers for widgets in body
    #
    after_body {
      @starting = false
    }

    ## Add widget content inside custom shell body
    ## Top-most widget must be a shell or another custom shell
    #
    body {
      shell {
        grid_layout {
          margin_width 0
          margin_height 0
          vertical_spacing 0
        }
        # Replace example content below with custom shell content
        minimum_size 1024, 768
        image File.join(APP_ROOT, 'package', 'linux', "Connector.png")
        text "Connector"
      
        composite {
          layout_data :fill, :center, true, false
          grid_layout(3, false) {
            margin_width 0
            margin_height 0
            margin_right 7
            horizontal_spacing 0
          }
          
          button {
            text '<'
            on_widget_selected {current_tab_browser.back}
          }
          button {
            text '>'
            on_widget_selected {current_tab_browser.forward}
          }
          # TODO enable the following after adding FontAwesome and using for Refresh and Stop
#           button {
#             text 'R'
#             on_widget_selected {current_tab_browser.refresh}
#           }
#           button {
#             text 'S'
#             on_widget_selected {current_tab_browser.stop}
#           }
          @web_url_text = text {
            layout_data :fill, :center, true, false
            text bind(self, :web_url)
            focus true # initial focus
            
            on_focus_gained {
              @web_url_text.select_all
            }
            
            on_key_pressed { |key_event|
              if key_event.keyCode == swt(:cr)
                self.web_url = "https://duckduckgo.com/?q=#{web_url}" if web_url.include?(' ') || !web_url.include?('.')
                current_tab_browser.url = web_url
              end
            }
          }
        }
        @tab_folder = tab_folder {
          layout_data :fill, :fill, true, true
          tab_item {
            fill_layout {
              margin_width 0
              margin_height 0
            }
            text 'New Tab'
            tab_browser
          }
          @plus_tab_item = tab_item {
            text '+'
          }
          on_widget_selected { |event|
            if !@starting && event.item.text == '+'
              add_tab_browser
            end
            self.web_url = current_tab_browser.url
          }
        }
        
        menu_bar {
          menu {
            text '&File'
            menu_item {
              text 'New &Tab'
              accelerator COMMAND, 't'
              
              on_widget_selected {
                add_tab_browser
              }
            }
            menu_item {
              text 'New &Window'
              accelerator COMMAND, 'n'
              
              on_widget_selected {
                app_view.open
              }
            }
            menu_item(:separator)
            menu_item {
              text '&Close Tab'
              accelerator COMMAND, 'w'
              
              on_widget_selected {
                new_selection_index = (@tab_folder.selection_index - 1) % (@tab_folder.items.size - 1)
                current_tab_item.dispose
                @tab_folder.selection = new_selection_index
              }
            }
            menu_item {
              text 'C&lose Window'
              accelerator COMMAND, :alt, 'q'
              
              on_widget_selected {
                current_shell.close
              }
            }
            # Enable the following once preferences are truly implemented
#             menu_item(:separator)
#             menu_item {
#               text '&Preferences...'
#               accelerator COMMAND, ','
#
#               on_widget_selected {
#                 display_about_dialog
#               }
#             }
          }
          menu {
            text '&Action'
            menu_item {
              text '&Back'
              accelerator(*(OS.mac? ? [COMMAND, '['] : [:alt, :arrow_left]))
              
              on_widget_selected {
                current_tab_browser.back
              }
            }
            menu_item {
              text '&Forward'
              accelerator(*(OS.mac? ? [COMMAND, ']'] : [:alt, :arrow_right]))
              
              on_widget_selected {
                current_tab_browser.forward
              }
            }
            menu_item {
              text '&Go To Address Bar'
              accelerator COMMAND, (OS.mac? ? 'l' : 'd')
              
              on_widget_selected {
                @web_url_text.set_focus
              }
            }
            menu_item {
              text '&Next Tab'
              accelerator COMMAND, :shift, ']'
              
              on_widget_selected {
                @tab_folder.selection = (@tab_folder.selection_index + 1) % (@tab_folder.items.size - 1)
              }
            }
            menu_item {
              text '&Previous Tab'
              accelerator COMMAND, :shift, '['
              
              on_widget_selected {
                @tab_folder.selection = (@tab_folder.selection_index - 1) % (@tab_folder.items.size - 1)
              }
            }
            menu_item {
              text '&Refresh'
              accelerator COMMAND, 'r'
              
              on_widget_selected {
                current_tab_browser.refresh
              }
            }
            menu_item {
              text '&Stop'
              accelerator COMMAND, 's'
              
              on_widget_selected {
                current_tab_browser.stop
              }
            }
          }
          menu {
            text '&Help'
            menu_item {
              text '&About...'
              accelerator COMMAND, :shift, 'a'
              
              on_widget_selected {
                display_about_dialog
              }
            }
          }
        }
      }
    }
    
    def tab_browser
      browser { |browser_proxy|
        layout_data :fill, :fill, true, true
        url "https://duckduckgo.com"
        
        on_changed {
          if !@starting
            self.web_url = browser_proxy.url
            domain = self.web_url.sub(/https?:\/\//, '').split('/').first
            current_tab_item.swt_tab_item.text = domain
            @tab_folder.redraw
            body_root.pack_same_size
          end
        }
        
        browser_proxy.swt_widget.add_title_listener { |event|
          body_root.text = "Connector (#{event.title})"
        }
      }
    end
    
    def current_shell
      display.focus_control.shell&.get_data('custom_shell')
    end
    
    def current_tab_browser
      current_tab_item.children.first.get_data('proxy')
    end
    
    def current_tab_item
      @tab_folder.selection.first.get_control.get_data('proxy')
    end
    
    def add_tab_browser
      @plus_tab_item.dispose
      new_tab = nil
      @tab_folder.content {
        new_tab = tab_item {
          fill_layout {
            margin_width 0
            margin_height 0
          }
          text 'New Tab'
          tab_browser
        }
        @plus_tab_item = tab_item {
          text '+'
        }
      }
      @tab_folder.redraw
      body_root.pack_same_size
      @tab_folder.selection = new_tab.swt_tab_item
    end

    def display_about_dialog
      message_box(body_root) {
        text 'About'
        message "Connector #{VERSION}\n\n#{LICENSE}"
      }.open
    end
    
  end
end
