require 'pd'
require 'glimmer-cw-browser-chromium'

class Connector
  class AppView
    include Glimmer::UI::CustomShell
    
    APP_ROOT = ::File.expand_path('../../..', __dir__)
    ICON = File.join(APP_ROOT, 'package', 'linux', "Connector.png")
    COMMAND = OS.mac? ? :command : :ctrl
    CONTROL = OS.mac? ? :ctrl : :alt
        
    ## Add options like the following to configure CustomShell by outside consumers
    #
    # options :title, :background_color
    # option :width, default: 320
    # option :height, default: 240
    option :engine, default: 'chromium'
    
    attr_accessor :web_url
    
    def engine_options
      ['chromium', 'webkit']
    end
    
    def chromium?
      engine.to_s == 'chromium'
    end
    
    def webkit?
      engine.to_s == 'webkit'
    end
    
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
          display_preferences_dialog
        }
        # Enable this when upgrading to glimmer-dsl-swt 4.18.x.y
#         on_quit {
#           exit(0)
#         }
        if OS.mac?
          display.swt_display.system_menu.items.find {|mi| mi.id == swt(:id_quit)}.add_selection_listener {
            exit(0)
          }
        end
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
        minimum_size 640, 480
        image ICON
        text "Connector"
        
        on_swt_show { |event|
          event.widget.set_size display.bounds.width, display.bounds.height
        }
      
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
                self.web_url = "http://#{web_url}" unless web_url.start_with?('http')
                current_tab_browser.set_url web_url
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
              accelerator swt(COMMAND, 't'.bytes.first)
              
              on_widget_selected {
                add_tab_browser
              }
            }
            menu_item {
              text 'New &Window'
              accelerator swt(COMMAND, 'n'.bytes.first)
              
              on_widget_selected {
                app_view.open
              }
            }
            menu_item(:separator)
            menu_item {
              text '&Close Tab'
              accelerator swt(COMMAND, 'w'.bytes.first)
              
              on_widget_selected {
                new_selection_index = (@tab_folder.selection_index - 1) % (@tab_folder.items.size - 1)
                current_tab_item.dispose
                @tab_folder.selection = new_selection_index
              }
            }
            menu_item {
              text 'C&lose Window'
              accelerator swt(COMMAND, :alt, 'q'.bytes.first)
              
              on_widget_selected {
                current_shell.close
              }
            }
            # Enable the following once preferences are truly implemented
            menu_item(:separator)
            menu_item {
              text '&Preferences...'
              accelerator swt(COMMAND, ','.bytes.first)

              on_widget_selected {
                display_preferences_dialog
              }
            }
            menu_item {
              text 'E&xit'
              accelerator swt(:alt, :f4)

              on_widget_selected {
                exit(0)
              }
            }
          }
          menu {
            text '&Action'
            menu_item {
              text '&Back'
              accelerator(*(OS.mac? ? swt(COMMAND, '['.bytes.first) : swt(:alt, :arrow_left)))
              
              on_widget_selected {
                current_tab_browser.back
              }
            }
            menu_item {
              text '&Forward'
              accelerator(*(OS.mac? ? swt(COMMAND, ']'.bytes.first) : swt(:alt, :arrow_right)))
              
              on_widget_selected {
                current_tab_browser.forward
              }
            }
            menu_item {
              text '&Go To Address Bar'
              accelerator swt(COMMAND, (OS.mac? ? 'l' : 'd').bytes.first)
              
              on_widget_selected {
                @web_url_text.set_focus
                @web_url_text.select_all
              }
            }
            menu_item {
              text '&Next Tab'
              accelerator swt(COMMAND, :shift, ']'.bytes.first)
              
              on_widget_selected {
                @tab_folder.selection = (@tab_folder.selection_index + 1) % (@tab_folder.items.size - 1)
                self.web_url = current_tab_browser.url
              }
            }
            menu_item {
              text '&Previous Tab'
              accelerator swt(COMMAND, :shift, '['.bytes.first)
              
              on_widget_selected {
                @tab_folder.selection = (@tab_folder.selection_index - 1) % (@tab_folder.items.size - 1)
                self.web_url = current_tab_browser.url
              }
            }
            menu_item {
              text '&Refresh'
              accelerator swt(COMMAND, 'r'.bytes.first)
              
              on_widget_selected {
                current_tab_browser.refresh
              }
            }
            menu_item {
              text '&Stop'
              accelerator swt(COMMAND, 's'.bytes.first)
              
              on_widget_selected {
                current_tab_browser.stop
              }
            }
          }
          menu {
            text '&Options'
            menu_item(:radio) {
              text '&Chromium'
              accelerator swt(COMMAND, :shift, 'c'.bytes.first)
              selection bind(self, :engine, on_read: ->(v) {v == 'chromium'}, on_write: ->(v) {v ? 'chromium' : 'webkit'})
            }
            menu_item(:radio) {
              text '&Webkit'
              accelerator swt(COMMAND, :shift, 'w'.bytes.first)
              selection bind(self, :engine, on_read: ->(v) {v == 'webkit'}, on_write: ->(v) {v ? 'webkit' : 'chromium'})
            }
          }
          menu {
            text '&Help'
            menu_item {
              text '&About...'
              accelerator swt(COMMAND, :shift, 'a'.bytes.first)
              
              on_widget_selected {
                display_about_dialog
              }
            }
          }
        }
      }
    }
    
    def tab_browser
      browser(engine) { |browser_proxy|
        layout_data :fill, :fill, true, true
        url "https://duckduckgo.com"
        
        on_changing { |event|
          if !@starting
            self.web_url = current_tab_browser.url
            domain = event.location.sub(/https?:\/\//, '').split('/').first
            current_tab_item.swt_tab_item.text = domain
            @tab_folder.redraw
            body_root.pack_same_size
            @web_url_text.set_focus
            @web_url_text.select_all
          end
        }
        
        browser_proxy.add_title_listener { |event|
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
      @tab_folder.selection = new_tab.swt_tab_item
      # TODO look into not remaximizing by remembering the same size
      body_root.set_size display.bounds.width, display.bounds.height
      body_root.pack_same_size
      @web_url_text.set_focus
      @web_url_text.select_all
    end

    def display_about_dialog
      dialog {
        grid_layout(2, false) {
          margin_width 15
          margin_height 15
        }
        
        background :white
        image ICON
        text 'About'
        
        label {
          layout_data :center, :center, false, false
          background :white
          image ICON, height: 260
        }
        label {
          layout_data :fill, :fill, true, true
          background :white
          text "Connector v#{VERSION} (Beta)\n\n#{LICENSE}\n\nConnector icon made by Freepik from www.flaticon.com"
        }
      }.open
    end

    def display_preferences_dialog
      dialog(body_root) {
        grid_layout(2, false)
        text 'Preferences'
        
        label {
          text "Default Engine"
          font style: :bold
        }
        radio_group {
          selection bind(self, :engine )
        }
      }.open
    end
    
  end
end
