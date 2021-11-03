require 'net/http'
require 'formdata'
require 'net/http/post/multipart'
require 'uri'
require 'resolv'

class Santtium
  def initialize

    @uri_santtium = 'http://api.santtium.sofnium.com/api/'
    @lst_step_result = []
    @step_result = {}
    @id_test_run = '88e33fac-4a07-4d97-754e-08d960cedd81'
    login
    super
  end

  private def login
    body = {
      userName: '',
      password: ''
    }
    response = Net::HTTP.post(URI("#{@uri_santtium}Auth/login"), body.to_json, 'Content-Type' => 'application/json')
    @token = JSON.parse(response.body)['result']['token']
  end

  def create_test_run
    body = {
      version: '4.0.1',
      idTestPlan: '43b934c4-6776-4e7e-658f-08d960de1e52',
      type: 0,
      idDevice: '2524361a-d2ca-4194-856a-08d960de43b5',
      idProject: '78bb2566-ffc1-4da9-56b4-08d960dd4181'
    }

    response = Net::HTTP.post(URI("#{@uri_santtium}TestRun/Add"),
                              body.to_json, { 'Content-Type' => 'application/json',
                                              'Authorization' => "Bearer #{@token}" })
    @id_test_run = JSON.parse(response.body)['result']
  end

  def get_step_by_feature_scenario(number_step, scenario, feature)
    step = {
      number: number_step,
      scenario: {
        description: scenario,
        feature: {
          idProject: '78bb2566-ffc1-4da9-56b4-08d960dd4181',
          description: feature
        }
      }
    }
    response = Net::HTTP.post(URI("#{@uri_santtium}Step/GetStepByFeatureScenarioNoStep"),
                              step.to_json,
                              { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{@token}" }
    )
    JSON.parse(response.body)['result']
  end

  def add_data_to_result(data)
    @step_result[:data] = data
  end

  def add_id_step_to_result(id_step)
    @step_result[:idStep] = id_step
  end

  def add_status_to_result(status)
    @step_result[:status] = status
  end

  def add_img_to_result(img)
    @step_result[:file] = img
  end

  def add_video_to_result(video)
    @step_result[:video] = video
  end

  def add_evidence
    @lst_step_result.push @step_result
    @step_result = {}
  end

  def add_scenarios_to_test_run()
    if @lst_step_result.size == 0
      puts 'lista de steps result vacia'
    end

    f = FormData.new
    i = 0
    key = 'stepsResult'
    @lst_step_result.each do |o|
      f.append "#{key}[#{i}].IdTestRun", @id_test_run
      f.append "#{key}[#{i}].IdStep", o[:idStep]
      f.append "#{key}[#{i}].Observations", o[:observations]
      f.append "#{key}[#{i}].Data", o['data']
      f.append "#{key}[#{i}].file", File.open(load_image(o[:file])), { content_type: 'image/png', filename: 'image.png' }
      f.append "#{key}[#{i}].Status", o[:status]
      i += 1
    end

    # f.append("results.VideoBase64", video) unless video.nil?

    # create a new net/http request
    req = Net::HTTP::Post.new('/api/TestRun/AddStepsResultToTestResult')
    req['Authorization'] = "Bearer #{@token}"
    req.content_type = f.content_type
    req.content_length = f.size
    req.body_stream = f

    # send the request
    http = Net::HTTP.new('api.santtium.sofnium.com')
    response = http.request(req) # => ...response
    puts JSON.parse response.body
  end

  def load_image(path_img)
    puts "Cargando image"
    image = MiniMagick::Image.open path_img
    image.dimensions
    puts "Dimensiones: #{image.dimensions}"
    puts "Peso original: #{image.human_size}"
    image.resize "768x1024"
    puts "Peso nuevo: #{image.human_size}"
    image.write path_img
    path_img
  end
end