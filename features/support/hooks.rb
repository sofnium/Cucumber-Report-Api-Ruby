Before do |scenario|
  @santtium = Santtium.new
  @step_no = 1
end

AfterStep do |scenario, step|
  result = if scenario.passed?
             0
           elsif scenario.failed?
             1
           elsif scenario.pending?
             2
           else
             1
           end

  step_info = @santtium&.get_step_by_feature_scenario @step_no, step.source[1].name, step.source[0].description
  @santtium&.add_img_to_result img
  @santtium&.add_status_to_result result
  @santtium&.add_id_step_to_result step_info['id']
  @santtium&.add_evidence
  @step_no += 1
end

After do |scenario|
  @santtium&.add_scenarios_to_test_run
end