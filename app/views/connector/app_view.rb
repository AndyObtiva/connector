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
        on_swt_keydown { |event|
          begin
            character = event.keyCode.chr rescue nil
            if event.stateMask == swt(COMMAND) && character == 'd'
              @web_url_text.select_all
              @web_url_text.set_focus
            elsif Glimmer::SWT::SWTProxy.include?(event.stateMask, COMMAND, :shift) && character == '['
              new_selection_index = (@tab_folder.selection_index - 1) % (@tab_folder.items.size - 1)
              @tab_folder.selection = new_selection_index
            elsif Glimmer::SWT::SWTProxy.include?(event.stateMask, COMMAND, :shift) && character == ']'
              new_selection_index = (@tab_folder.selection_index + 1) % (@tab_folder.items.size - 1)
              @tab_folder.selection = new_selection_index
            elsif event.stateMask == swt(COMMAND) && character == '['
              current_tab_browser.back
            elsif event.stateMask == swt(COMMAND) && character == ']'
              current_tab_browser.forward
            elsif event.stateMask == swt(COMMAND) && character == 'r'
              current_tab_browser.refresh
            elsif event.stateMask == swt(COMMAND) && character == 's'
              current_tab_browser.stop
            elsif event.stateMask == swt(COMMAND) && character == 't'
              add_tab_browser
            elsif event.stateMask == swt(COMMAND) && character == 'w'
              new_selection_index = (@tab_folder.selection_index - 1) % (@tab_folder.items.size - 1)
              current_tab_item.dispose
              @tab_folder.selection = new_selection_index
            elsif event.stateMask == swt(COMMAND) && character == 'n'
              app_view.open
            end
          rescue => e
            pd e
          end
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
              text '&About...'
              on_widget_selected {
                display_about_dialog
              }
            }
            menu_item {
              text '&Preferences...'
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
            @tab_folder.redraw
            body_root.pack_same_size
          end
        }
        
        browser_proxy.swt_widget.add_title_listener { |event|
          body_root.text = "Connector (#{event.title})"
        }
      }
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
