Sequel.migration do
  change do
    create_table(:bearers) do
      primary_key :id
      column :from_ofcom, TrueClass # boolean
      column :type, String
      column :frequency, String, :size => 6 # for FM
      column :service_id, String, :size => 4
    end

    create_table(:services) do
      primary_key :id
      column :from_ofcom, TrueClass # boolean
      column :rds_ps, String
    end

    create_table(:transmitters) do
      primary_key :id
      column :name, String
      column :area, String
      column :lat, String
      column :long, String
      column :updated_at, DateTime
    end

    create_table(:multiplexes) do
      primary_key :id
      column :eid, String, :size => 4, :unique => true
      column :name, String
      column :area, String
      column :block, String
      column :frequency, String
      column :licence_number, String
      column :updated_at, DateTime
    end
  end
end

