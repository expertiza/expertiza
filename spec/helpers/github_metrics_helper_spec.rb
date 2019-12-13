describe GithubMetricsHelper, type: :helper do
  describe 'display_github_matrices' do
    context "when graph type is number of commits and group by week" do
      it 'should return commits group by week' do
        git_variable = {}

        git_variable[:parsed_data] = {
          "tushar.h.dahibhate@gmail.com"=>{
            "2018-11-14"=> {
              :commits=>1, :additions=>2, :deletions=>2
            }, 
            "2018-11-23"=> {
              :commits=>0, :additions=>0, :deletions=>0
            }
          }, 
          "ssbhoyar@gmail.com"=>{
            "2018-11-14"=>{
              :commits=>0, :additions=>0, :deletions=>0
            }, 
            "2018-11-23"=>{
              :commits=>1, :additions=>0, :deletions=>3292
            }
          }
        }
        git_variable[:authors] = ["tushar.h.dahibhate@gmail.com", "ssbhoyar@gmail.com"]
        git_variable[:dates] = ["2018-11-14", "2018-11-23"]
        graph_type = '0'
        timeline_type = '0'
        due_date = "2017-09-08 23:59:00 -0400"
        
        data = helper.get_chart_data(git_variable, graph_type, timeline_type, due_date)

        expected_data = {
          :labels=>[-10, -11],
          :datasets=>[
            {"borderWidth"=>1, "data"=>[1, 0], "stack"=>1, "label"=>"tushar.h.dahibhate@gmail.com", "backgroundColor"=>"#ed1c1c"},
            {"borderWidth"=>1, "data"=>[0, 1], "stack"=>1, "label"=>"ssbhoyar@gmail.com", "backgroundColor"=>"#ffea00"}
          ]
        }

        expect(data).to eq(expected_data)
      end
    end

    context "when graph type is lines added and group by week" do
      it 'should return commits group by week' do
        git_variable = {}

        git_variable[:parsed_data] = {
          "tushar.h.dahibhate@gmail.com"=>{
            "2018-11-14"=> {
              :commits=>1, :additions=>2, :deletions=>2
            }, 
            "2018-11-23"=> {
              :commits=>0, :additions=>5, :deletions=>0
            }
          }, 
          "ssbhoyar@gmail.com"=>{
            "2018-11-14"=>{
              :commits=>0, :additions=>6, :deletions=>0
            }, 
            "2018-11-23"=>{
              :commits=>1, :additions=>3, :deletions=>3292
            }
          }
        }
        git_variable[:authors] = ["tushar.h.dahibhate@gmail.com", "ssbhoyar@gmail.com"]
        git_variable[:dates] = ["2018-11-14", "2018-11-23"]
        graph_type = '1'
        timeline_type = '0'
        due_date = "2017-09-08 23:59:00 -0400"
        
        data = helper.get_chart_data(git_variable, graph_type, timeline_type, due_date)

        expected_data = {
          :labels=>[-10, -11],
          :datasets=>[
            {"borderWidth"=>1, "data"=>[2, 5], "stack"=>2, "label"=>"tushar.h.dahibhate@gmail.com", "backgroundColor"=>"#ed1c1c"},
            {"borderWidth"=>1, "data"=>[6, 3], "stack"=>2, "label"=>"ssbhoyar@gmail.com", "backgroundColor"=>"#ffea00"}
          ]
        }

        expect(data).to eq(expected_data)
      end
    end

    context "when graph type is lines deleted and group by week" do
      it 'should return lines deleted group by week' do
        git_variable = {}

        git_variable[:parsed_data] = {
          "tushar.h.dahibhate@gmail.com"=>{
            "2018-11-14"=> {
              :commits=>1, :additions=>2, :deletions=>2
            }, 
            "2018-11-23"=> {
              :commits=>0, :additions=>5, :deletions=>0
            }
          }, 
          "ssbhoyar@gmail.com"=>{
            "2018-11-14"=>{
              :commits=>0, :additions=>6, :deletions=>0
            }, 
            "2018-11-23"=>{
              :commits=>1, :additions=>3, :deletions=>3292
            }
          }
        }
        git_variable[:authors] = ["tushar.h.dahibhate@gmail.com", "ssbhoyar@gmail.com"]
        git_variable[:dates] = ["2018-11-14", "2018-11-23"]
        graph_type = '2'
        timeline_type = '0'
        due_date = "2017-09-08 23:59:00 -0400"
        
        data = helper.get_chart_data(git_variable, graph_type, timeline_type, due_date)

        expected_data = {
          :labels=>[-10, -11],
          :datasets=>[
            {"borderWidth"=>1, "data"=>[2, 0], "stack"=>3, "label"=>"tushar.h.dahibhate@gmail.com", "backgroundColor"=>"#ed1c1c"},
            {"borderWidth"=>1, "data"=>[0, 3292], "stack"=>3, "label"=>"ssbhoyar@gmail.com", "backgroundColor"=>"#ffea00"}
          ]
        }

        expect(data).to eq(expected_data)
      end
    end

    context "when graph type is lines added and group by student" do
      it 'should return commits group by student' do
        git_variable = {}

        git_variable[:parsed_data] = {
          "tushar.h.dahibhate@gmail.com"=>{
            "2018-11-14"=> {
              :commits=>1, :additions=>2, :deletions=>2
            }, 
            "2018-11-23"=> {
              :commits=>0, :additions=>5, :deletions=>0
            }
          }, 
          "ssbhoyar@gmail.com"=>{
            "2018-11-14"=>{
              :commits=>0, :additions=>6, :deletions=>0
            }, 
            "2018-11-23"=>{
              :commits=>1, :additions=>3, :deletions=>3292
            }
          }
        }
        git_variable[:authors] = ["tushar.h.dahibhate@gmail.com", "ssbhoyar@gmail.com"]
        git_variable[:dates] = ["2018-11-14", "2018-11-23"]
        graph_type = '0'
        timeline_type = '1'
        due_date = "2017-09-08 23:59:00 -0400"
        
        data = helper.get_chart_data(git_variable, graph_type, timeline_type, due_date)

        expected_data = {
          :labels => ["tushar.h.dahibhate@gmail.com", "ssbhoyar@gmail.com"],
          :datasets=>[
            {"borderWidth"=>1, "data"=>[1, 0], "stack"=>1, "label"=>"Week:46", "backgroundColor"=>"#ed1c1c"},
            {"borderWidth"=>1, "data"=>[0, 1], "stack"=>1, "label"=>"Week:47", "backgroundColor"=>"#ffea00"}
          ]
        }

        expect(data).to eq(expected_data)
      end
    end

    context "when graph type is lines added and group by student" do
      it 'should return lines added group by student' do
        git_variable = {}

        git_variable[:parsed_data] = {
          "tushar.h.dahibhate@gmail.com"=>{
            "2018-11-14"=> {
              :commits=>1, :additions=>2, :deletions=>2
            }, 
            "2018-11-23"=> {
              :commits=>0, :additions=>5, :deletions=>0
            }
          }, 
          "ssbhoyar@gmail.com"=>{
            "2018-11-14"=>{
              :commits=>0, :additions=>6, :deletions=>0
            }, 
            "2018-11-23"=>{
              :commits=>1, :additions=>3, :deletions=>3292
            }
          }
        }
        git_variable[:authors] = ["tushar.h.dahibhate@gmail.com", "ssbhoyar@gmail.com"]
        git_variable[:dates] = ["2018-11-14", "2018-11-23"]
        graph_type = '1'
        timeline_type = '1'
        due_date = "2017-09-08 23:59:00 -0400"
        
        data = helper.get_chart_data(git_variable, graph_type, timeline_type, due_date)

        expected_data = {
          :labels => ["tushar.h.dahibhate@gmail.com", "ssbhoyar@gmail.com"],
          :datasets=>[
            {"borderWidth"=>1, "data"=>[2, 6], "stack"=>2, "label"=>"Week:46", "backgroundColor"=>"#ed1c1c"},
            {"borderWidth"=>1, "data"=>[5, 3], "stack"=>2, "label"=>"Week:47", "backgroundColor"=>"#ffea00"}
          ]
        }

        expect(data).to eq(expected_data)
      end
    end

    context "when graph type is lines deleted and group by student" do
      it 'should return lines deleted group by student' do
        git_variable = {}

        git_variable[:parsed_data] = {
          "tushar.h.dahibhate@gmail.com"=>{
            "2018-11-14"=> {
              :commits=>1, :additions=>2, :deletions=>2
            }, 
            "2018-11-23"=> {
              :commits=>0, :additions=>5, :deletions=>0
            }
          }, 
          "ssbhoyar@gmail.com"=>{
            "2018-11-14"=>{
              :commits=>0, :additions=>6, :deletions=>0
            }, 
            "2018-11-23"=>{
              :commits=>1, :additions=>3, :deletions=>3292
            }
          }
        }
        git_variable[:authors] = ["tushar.h.dahibhate@gmail.com", "ssbhoyar@gmail.com"]
        git_variable[:dates] = ["2018-11-14", "2018-11-23"]
        graph_type = '2'
        timeline_type = '1'
        due_date = "2017-09-08 23:59:00 -0400"
        
        data = helper.get_chart_data(git_variable, graph_type, timeline_type, due_date)

        expected_data = {
          :labels => ["tushar.h.dahibhate@gmail.com", "ssbhoyar@gmail.com"],
          :datasets=>[
            {"borderWidth"=>1, "data"=>[2, 0], "stack"=>3, "label"=>"Week:46", "backgroundColor"=>"#ed1c1c"},
            {"borderWidth"=>1, "data"=>[0, 3292], "stack"=>3, "label"=>"Week:47", "backgroundColor"=>"#ffea00"}
          ]
        }

        expect(data).to eq(expected_data)
      end
    end
  end
end
