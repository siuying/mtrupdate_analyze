module Mtrupdate
  class API < Grape::API
    version 'v1', using: :header, vendor: 'mtrupdate'
    format :json

    resource :statuses do
      desc "Return recent en status of mtrupdate."
      get :en do
        Mtrupdate::Tweet.where(:lang => "en").limit(20).collect{|e| e.to_hash }
      end

      desc "Return recent zh status of mtrupdate."
      get :zh do
        Mtrupdate::Tweet.where(:lang => "zh").limit(20).collect{|e| e.to_hash }
      end
    end
  end
end