module ApplicationHelper

  #-----------------------------------------------------------------------------
  # Create a tooltip icon and text for the given id
  #-----------------------------------------------------------------------------
  def create_tooltip(id, tooltip_text)
    html =  "<span id=\"#{id}_tooltip\" "
    html += "style=\"margin: 5px; background-color: white; color: black; border: 1px solid black;\">"
    html += tooltip_text
    html += "</span>"
    
    html += "<span id=\"#{id}_tooltip_icon\" class=\"tooltip_icon\">?</span>"
    html += "<script type=\"text/javascript\">"
    html += "var my_tooltip = new Tooltip(\"#{id}_tooltip_icon\", \"#{id}_tooltip\")"
    html += "</script>\n"
    html
  end
 
  #-----------------------------------------------------------------------------
  # Format a time object with the specified format
  #-----------------------------------------------------------------------------
  def format_time(time)
    time.strftime("%B %d, %Y %I:%M%p")
  end
 
end
