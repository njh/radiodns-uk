Sequel.migration do
  change do
    create_table(:bearers) do
      primary_key :id
      column :type, Integer, :size => 1, :index => true
      column :frequency, Float # for FM
      column :sid, String, :size => 4, :index => true
      column :eid, String, :size => 4, :index => true
      column :scids, String, :size => 1, :index => true, :default => '0'
      column :multiplex_id, Integer, :index => true
      column :authority_id, Integer, :index => true
      column :service_id, Integer, :index => true
      column :bitrate, Integer
      column :cost, Integer
      column :offset, Integer
      column :mime_type, String
      column :from_ofcom, FalseClass, :default => false # boolean
      column :ofcom_label, String
    end

    create_table(:authorities) do
      primary_key :id
      column :fqdn, String, :unique => true
      column :name, String
      column :description, String
      column :link, String
      column :logo, String
      column :radioepg_server, String
      column :radiotag_server, String
      column :radiovis_server, String
      column :radioweb_server, String
      column :updated_at, DateTime
    end

    create_table(:services) do
      primary_key :id
      column :default_bearer_id, Integer
      column :authority_id, Integer
      column :sort_name, String
      column :short_name, String
      column :medium_name, String
      column :long_name, String
      column :short_description, String
      column :long_description, String, :text => true
    end

    create_table(:transmitters) do
      primary_key :id
      column :ngr, String, :size => 8, :unique => true
      column :name, String
      column :area, String
      column :county, String
      column :lat, Float
      column :long, Float
      column :site_height, Integer
      column :total_power, Float
      column :updated_at, Date
    end

    create_table(:multiplexes) do
      primary_key :id
      column :eid, String, :size => 4, :unique => true
      column :name, String
      column :area, String
      column :block, String
      column :frequency, Float
      column :licence_number, String
      column :updated_at, Date
    end

    create_table(:multiplexes_transmitters) do
      column :multiplex_id, Integer
      column :transmitter_id, Integer
      index [:multiplex_id, :transmitter_id], :unique => true
    end

    create_table(:bearers_transmitters) do
      column :bearer_id, Integer
      column :transmitter_id, Integer
      index [:bearer_id, :transmitter_id], :unique => true
    end

    create_table(:links) do
      primary_key :id
      column :service_id, Integer, :index => true
      column :uri, String, :index => true
      column :description, String
      column :mime_type, String
    end

    create_table(:logos) do
      primary_key :id
      column :service_id, Integer, :index => true
      column :size, String, :index => true, :size => 12
      column :url, String
      column :mime_type, String
      index [:service_id, :size], :unique => true
    end

    create_table(:genres) do
      primary_key :id
      column :urn, String, :index => true
      column :name, String
    end

    create_table(:genres_services) do
      column :genre_id, Integer
      column :service_id, Integer
      index [:genre_id, :service_id], :unique => true
    end

  end
end

