module OutingHelper

  def generate_outings_table(outings, suggested = false)
    html =  "<div class=\"outing_table\">\n"
    html += "<table>\n"
    html += "  <tr>\n"
    html += "    <th style=\"width: 25%\">"
    html += "Date" unless suggested
    html += "</th>\n"
    html += "    <th style=\"width: 25%\">Restaurant</th>\n"
    html += "    <th style=\"width: 25%\">Location</th>\n"
    html += "    <th style=\"width: 25%\">"
    html += "Sponsor" unless suggested
    html += "</th>\n"
    html += "  </tr>\n"

    for outing in outings
      html += "  <tr>\n"
      html += "    <td>"
      html += format_time(outing.reservation_time) unless suggested
      html += "    </td>\n"
      html += "    <td>" + link_to(outing.restaurant_name, :action => 'show', :id => outing) + "</td>\n"
      html += "    <td>" + h(outing.restaurant_city) + ", " + h(outing.restaurant_state) + "</td>\n"
      html += "    <td>" + h(outing.diner.display_name) + "</td>\n" unless suggested
      html += "  </tr>\n"
    end
    
    html += "</table>\n"
    html += "</div>\n"
  end

  def generate_diner_directions_section(outing, diners)
    url = url_for :action => :get_directions_to_restaurant, :id => outing

    html = '<span id="diner_directions_link">'
    html += link_to 'Get directions for', 
      { :action => :get_directions_to_restaurant, :id => outing, :diner_name => diners.first.comma_seperated_display_name }, 
      :target => 'new' 
    html += '</span> '
    html += select_tag 'diner_selector', generate_diner_options(diners),
      :onchange => "updateDinerDirectionsLink('#{url}');"
  end
  
  def generate_sponsor_dropdown(diners)
    select('outing', 'diner_id',
      diners.collect {|d| [ "#{d.comma_seperated_display_name}", d.id ]}, 
      { :include_blank => true })
  end
  
  def generate_afterparty_sponsor_dropdown(afterparty_sponsor, diners)
    options = ""
    for diner in diners 
      unless diner.address_line_1.blank?
        options << "<option"
        options << " selected=\"selected\"" if afterparty_sponsor == diner
        options << ">#{diner.comma_seperated_display_name}</option>"
      end
    end
    select_tag('afterparty_sponsor_name', options)
  end
  
  def generate_reservation_time_select(outing)
    my_select_time = outing.reservation_time || Time.now
    select_month(my_select_time) + ' ' + select_year(my_select_time) + ' - ' + 
      select_time(my_select_time, { :time_separator => ': ' } )
  end
  
  def linkify(link)
    "<a href=\"http://#{link}\" target=\"new\">http://#{link}</a>"
  end

  def generate_diners_list(diners)
    html = "<ul>"
    diners.sort! { |x,y| "#{x.last_name}#{x.first_name}" <=> "#{y.last_name}#{y.first_name}" }
    for diner in diners
      html += "<li>#{h(diner.comma_seperated_display_name)}</li>\n"
    end
    html += "</ul>"
    html
  end

  def generate_diner_checkboxes(diners, attending_diners, declined_diners)
    html = "<p><strong>Who's In?</strong>\n"
    html += create_tooltip("attendee_header", "Select the check boxes to indicate who's coming") + "</p>\n"

    html += "<table class=\"detailed_info\">\n"
    html += "<th>Diner</th>\n"
    html += "<th>In</th>\n"
    html += "<th>Out</th>\n"

    for diner in diners
      html += "<tr>\n"
      html += "<td>#{h(diner.comma_seperated_display_name)}:</td>"

      checked = false
      checked = true if attending_diners.include?(diner)
      html += "<td>#{check_box_tag('attending_' + diner.id.to_s, '1', checked)}</td>"

      checked = false
      checked = true if declined_diners.include?(diner)
      html += "<td>#{check_box_tag('declined_' + diner.id.to_s, '1', checked)}</td>"

      html += "</tr>"
    end
    html += "</table>"
    html
  end

  def display_afterparty_address(outing)
    bar_name = ''
    if (!outing.afterparty_sponsor.blank?)
      diner = Diner.find(outing.afterparty_sponsor)
      bar_name = "The home of #{diner.first_name} #{diner.last_name}"
    elsif (!outing.afterparty_bar_name.blank?)
      bar_name = outing.afterparty_bar_name
    end

    location = outing.afterparty_location
    html  = h(bar_name) + '<br /><br />'
    html += h(location[:address]) + '<br />'
    html += h(location[:city]) + ', ' + h(location[:state]) + ' ' + h(location[:zip]) + '<br />'
  end

  private
  
  def generate_diner_options(diners)
    option_tags = ''
    for diner in diners
      option_tags << "<option>#{diner.comma_seperated_display_name}</option>"
    end
    option_tags
  end

end
