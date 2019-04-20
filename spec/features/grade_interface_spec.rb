include GradeInterfaceHelperSpec

describe 'Integration tests for viewing grades: ' do
  before(:each, &method(:assignment_setup))

  describe 'When the assignment does not have a rubric' do
    it 'displays the average of all assignment grades'
    # login_as("instructor6")
    # visit '/grades/view?id=1'
    # expect(page).to have_content('Summary report')
    #
    it 'does not display the rubric statistics for this assignment'
    it 'displays the distribution of all assignment grades'
  end

  describe 'When the assignment has a rubric' do
    it 'displays the average of all assignment grades'
    it 'displays the distribution of all assignment grades'
    context 'with only one round' do
      it 'displays the rubric statistics for the assignment'
      it 'displays the "Analyze" tab'
      it 'displays the "Compare" tab as not selectable'
      it 'displays the mean criteria scores on the graph'
      it 'displays "Round 1"'
      it 'does not allow selection of a different round'
      it 'displays all rubric criteria as selected'
      it 'displays "Mean" in the stat selection menu'
      describe 'reactions to rubric statistics' do
        context 'when median is selected' do
          it 'displays "Round 1"'
          it 'displays the median criteria scores on the graph'
          it 'retains selection of all criteria'
          it 'displays "Median" in the stat selection menu'
          describe 'then, when one criterion is deselected' do
            it 'removes the deselected criterion score from the graph'
            describe 'then, when mean is selected' do
              it 'retains the previously selected criteria'
              it 'displays the selected means on the graph'
              describe 'then, when more than one criterion is deselected' do
                it 'removes the deselected criteria from the graph'
                describe 'then, when all criteria are deselected' do
                  it 'removes all mean criteria scores from the graph'
                  describe 'then, when median is selected' do
                    it 'retains a blank graph'
                  end
                end
              end
            end
          end
        end
      end
    end
    context 'with more than one round' do
      it 'displays the rubric statistics for the assignment'
      it 'displays the "Analyze" tab'
      it 'displays the "Compare" tab as not selectable'
      it 'displays the mean criteria scores on the graph'
      it 'displays "Round 1"'
      it 'displays "Round 1" in the round selection menu'
      it 'displays all rubric criteria as selected'
      it 'displays "Mean" in the stat selection menu'
      describe 'reactions to rubric statistics' do
        context 'when a different round is selected' do
          it 'displays the chosen round in the round selection menu'
          it 'displays all rubric criteria as selected'
          it 'displays the mean criteria scores on the graph'
          describe 'and median is selected' do
            it 'displays the median criteria scores on the graph'
            it 'retains selection of all criteria'
            it 'displays "Median" in the stat selection menu'
            describe 'then, when one criterion is deselected' do
              it 'removes the deselected criterion score from the graph'
            end
          end
        end
      end
    end

    context 'when more than one assignment has rubrics' do
      it 'displays the "Analyze" tab'
      describe 'two assignments with rubrics' do
        context 'when the criteria are not compatible' do
          it 'displays the "Compare" tab as not selectable'
        end
        context 'when the criteria are compatible' do
          it 'displays the "Compare" tab as selectable'
          describe 'then, when the Compare tab is selected' do
            it 'displays the "Assignment" drop down menu'
            it 'displays both rubric averages'
            describe 'then, when a criterion is deselected' do
              it 'removes the deselected criterion from the graph'
              describe 'then, when median is selected' do
                it 'displays the median criteria scores on the graph'
                it 'retains the previously selected criteria'
                it 'displays "Median" in the stat selection menu'
              end
            end
          end
        end
      end
    end
  end

end
