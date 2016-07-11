class MetareviewScore < ActiveRecord::Base


  def AutomatedMetareviewWebScore (reviewText)

    webservice_url=WEBSERVICE_CONFIG["metareview_webservice_url"]
    automatedMetareviewWebScore=Hash.new
    #for testing
    automatedMetareviewWebScore["volume"] =0
    automatedMetareviewWebScore["tone_negative"]=0.0
    automatedMetareviewWebScore["tone_neutral"]=0.0
    automatedMetareviewWebScore["tone_positive"]=0.0
    automatedMetareviewWebScore["problem_identification"]=0.0
    automatedMetareviewWebScore["summative"]=0.0
    automatedMetareviewWebScore["advisory"]=0.0
    automatedMetareviewWebScore["relevance"]=0.0
    automatedMetareviewWebScore["coverage"]=0.0
    automatedMetareviewWebScore["plagiarism"]=false

    #tone
    webMethod=webservice_url+'tone'
    serviceResult=RestClient.post webMethod, {'reviews'=>reviewText}, :content_type=>:json, :accept=>:json
    serviceResult=JSON.parse(serviceResult)
    automatedMetareviewWebScore["tone_negative"]=serviceResult["tone_negative"]
    automatedMetareviewWebScore["tone_neutral"]=serviceResult["tone_neutral"]
    automatedMetareviewWebScore["tone_positive"]=serviceResult["tone_positive"]

    #volume
    webMethod=webservice_url+'volume'
    serviceResult=RestClient.post webMethod, {'reviews'=>reviewText}, :content_type=>:json, :accept=>:json
    serviceResult=JSON.parse(serviceResult)
    automatedMetareviewWebScore["volume"]=serviceResult["volume"]

    #content
    webMethod=webservice_url+'content'
    serviceResult=RestClient.post 'http://localhost:3001/metareviewgenerator/content', {'reviews'=>reviewText}, :content_type=>:json, :accept=>:json
    serviceResult=JSON.parse(serviceResult)
    automatedMetareviewWebScore["problem_identification"]=serviceResult["content_summative"]
    automatedMetareviewWebScore["summative"]=serviceResult["content_problem"]
    automatedMetareviewWebScore["advisory"]=serviceResult["content_advisory"]

    return automatedMetareviewWebScore

  end
end
