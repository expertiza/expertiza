module GithubMetricsHelper
  def display_github_metrics(parsed_data, authors, dates)
    data_array = []
    color = %w[red yellow blue gray green magenta]
    i = 0
    mapped_data = {}
    authors.each do |author|
      mapped_author = remap_author(author)
      if mapped_data.include? mapped_author
        mapped_data[mapped_author] = [mapped_data[mapped_author], parsed_data[author].values].transpose.map {|x| x.reduce(:+)}
      else
        mapped_data[mapped_author] = parsed_data[author].values
      end
    end
    remap_authors(authors).uniq.each do |m_author|
      data_object = {}
      #m_author = remap_author(author)
      data_object['label'] = m_author
      #data_object['data'] = parsed_data[author].values
      data_object['data'] = mapped_data[m_author]
      data_object['backgroundColor'] = color[i]
      data_object['borderWidth'] = 1
      data_array.push(data_object)
      i += 1
      i = 0 if i > 5
    end

    data = {
      labels: dates,
      datasets: data_array
    }
    horizontal_bar_chart data, chart_options
  end

  def chart_options
    {
    responsive: true,
    maintainAspectRatio: false,
    width: 100,
    height: 100,
    scales: graph_scales
     }
  end

  def graph_scales
    {
     yAxes: [{
              stacked: true,
              ticks: {
               beginAtZero: true
              },
              barThickness: 30,
              scaleLabel: {
               display: true,
               labelString: 'Submission timeline'
               }
              }],
     xAxes: [{
              stacked: true,
              ticks: {
               beginAtZero: true
              },
              barThickness: 30,
              scaleLabel: {
               display: true,
               labelString: '# of Commits'
              }
             }]
      }
  end

  def should_check(email, student)
    if params[email] == student
      return "checked"
    end
    return ""
  end

  def remap_author(email)
    if params[email]
      return params[email]
    end
    return email
  end

  def remap_authors(emails)
    return emails.map { | e | remap_author(e) }
  end
      
end

