require 'rubygems'
require 'shoes'
require 'gollum'
require 'gollum/app'

module GollumLauncher
  THREAD_OK_STATUS = ['run', 'sleep']
  def gollum_running?
    @gollum_thread && THREAD_OK_STATUS.include?(@gollum_thread.status)
  end
  
  def exit_gollum
    @gollum_thread.exit
  end
  
  def run_gollum(path, bind, port, wiki_options)
    Precious::App.set(:wiki_options, nil) # Reset the settings in case they were modified on an earlier run.    
    Precious::App.set(:gollum_path, path)
    Precious::App.set(:wiki_options, wiki_options)
    Precious::App.run!({:port => port, :bind => bind})
  end
  
  def set_status(msg)
    @status.text = "\n\n#{msg}"
  end
  
  def toggle_running
    elements = [@allow_uploads, @location, @path]
    elements.each do |element|
      new_state = element.style[:state] == 'disabled' ? nil : 'disabled'
      element.style(state: new_state)
    end
  end
  
  def get_settings
    if @path.text.empty?
      alert('Please specify the location for your wiki first!')
      return nil
    end
    wiki_options = parse_uploads_settings
    return [@path.text.dup, '0.0.0.0', '4567', wiki_options]
  end
  
  def parse_uploads_settings
    case @allow_uploads.text
    when UPLOADS_PAGE_TEXT
      {:allow_uploads => true, :per_page_uploads => true}
    when UPLOADS_DIR_TEXT
      {:allow_uploads => true}
    else
      {}
    end
  end
  
end

Shoes.app do
  
  extend GollumLauncher
  
  UPLOADS_DIR_TEXT = 'Store in /uploads'
  UPLOADS_PAGE_TEXT = 'Store per page'
  
  stack displace_left: 15, displace_top: 15 do

    subtitle 'Gollum Settings'

    stack displace_left: 15, displace_top: 15 do

      flow do
        caption 'Wiki Location: '
        @path = edit_line
        @location = button 'Choose' do
          @path.text = ask_open_folder
        end
      end

      flow do
        caption 'Allow Uploads: '
        @allow_uploads = list_box items: ['No', UPLOADS_DIR_TEXT, UPLOADS_PAGE_TEXT], choose: UPLOADS_DIR_TEXT
      end
      
      flow do
        RUN_TEXT = 'Run Gollum'
        STOP_TEXT = 'Stop Gollum'
        
        @run_btn = button(RUN_TEXT) do |run_btn|
          if gollum_running?
            run_btn.text = RUN_TEXT
            exit_gollum
            set_status('Stopped Gollum')
            toggle_running
          elsif settings = get_settings
            @gollum_thread = Thread.new do
              run_gollum(*settings)
            end
            if gollum_running?
              toggle_running
              run_btn.text = STOP_TEXT
              set_status('Gollum is running on 127.0.0.1:4567')
            else
              set_status('Gollum failed to run!')
            end
          end
        end
        
        @status = para ''
      end
      
    end
  end
  
end