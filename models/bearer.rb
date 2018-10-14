class Bearer < Sequel::Model
  TYPE_DAB = 1
  TYPE_FM = 2

  many_to_one :multiplex

end

# Table: bearers
# Columns:
#  id           | integer      | PRIMARY KEY AUTOINCREMENT
#  type         | integer      |
#  frequency    | varchar(6)   |
#  sid          | varchar(4)   |
#  eid          | varchar(4)   |
#  multiplex_id | integer      |
#  from_ofcom   | boolean      |
#  ofcom_label  | varchar(255) |
# Indexes:
#  bearers_eid_index          | (eid)
#  bearers_multiplex_id_index | (multiplex_id)
#  bearers_sid_index          | (sid)
#  bearers_type_index         | (type)
