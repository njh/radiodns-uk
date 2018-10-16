Sequel.migration do
  change do
    create_table(:bearers) do
      primary_key :id
      column :type, Integer, :size => 1, :index => true
      column :frequency, String, :size => 6 # for FM
      column :sid, String, :size => 4, :index => true
      column :eid, String, :size => 4, :index => true
      column :scids, String, :size => 1, :index => true, :default => '0'
      column :multiplex_id, Integer, :index => true
      column :authority_id, Integer, :index => true
      column :from_ofcom, TrueClass # boolean
      column :ofcom_label, String
    end

    create_table(:authorities) do
      primary_key :id
      column :fqdn, String, :unique => true
    end

    create_table(:services) do
      primary_key :id
      column :from_ofcom, TrueClass # boolean
      column :rds_ps, String
    end

    create_table(:transmitters) do
      primary_key :id
      column :ngr, String, :size => 8, :unique => true
      column :name, String
      column :area, String
      column :lat, Float
      column :long, Float
      column :updated_at, Date
    end

    create_table(:multiplexes) do
      primary_key :id
      column :eid, String, :size => 4, :unique => true
      column :name, String
      column :area, String
      column :block, String
      column :frequency, String
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
  end
end

