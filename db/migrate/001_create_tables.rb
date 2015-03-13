class CreateTables < ActiveRecord::Migration
  def self.up

    create_table "coupons", :force => true do |t|
      t.string   "code",          :limit => 16,                                :default => "",  :null => false
      t.string   "description",   :limit => 64,                                :default => "",  :null => false
      t.string   "coupon",        :limit => 64,                                :default => "",  :null => false
      t.string   "product_code",  :limit => 16,                                :default => "",  :null => false
      t.decimal  "amount",                      :precision => 10, :scale => 2, :default => 0.0, :null => false
      t.integer  "percentage"
      t.integer  "used_count"
      t.integer  "use_limit",                                                  :default => 1,   :null => false
      t.datetime "creation_time"
      t.integer  "numdays",                                                    :default => 0,   :null => false
    end

    add_index "coupons", ["coupon"], :name => "coupon"

    create_table "currencies", :force => true do |t|
      t.string   "code",       :limit => 3,                                                      :null => false
      t.string   "unit",       :limit => 10,                                 :default => "$"
      t.integer  "precision",                                                :default => 2
      t.string   "separator",  :limit => 2,                                  :default => "."
      t.string   "delimiter",  :limit => 2,                                  :default => ","
      t.string   "format",     :limit => 16,                                 :default => "%u%n"
      t.decimal  "rate",                     :precision => 12, :scale => 10, :default => 0.0
      t.string   "countries"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "line_items", :force => true do |t|
      t.integer "order_id",                                                  :default => 0,   :null => false
      t.integer "product_id",                                                :default => 0,   :null => false
      t.integer "quantity",                                                  :default => 0,   :null => false
      t.decimal "unit_price",                 :precision => 10, :scale => 2, :default => 0.0, :null => false
      t.string  "license_key", :limit => 128
    end

    add_index "line_items", ["order_id"], :name => "order_id"
    add_index "line_items", ["product_id"], :name => "product_id"

    create_table "list_subscribers", :force => true do |t|
      t.text "email", :null => false
    end

    create_table "orders", :force => true do |t|
      t.integer  "coupon_id"
      t.string   "status",             :limit => 1,                                   :default => "P", :null => false
      t.string   "email",              :limit => 128,                                 :default => "",  :null => false
      t.datetime "order_time"
      t.string   "first_name",         :limit => 64
      t.string   "licensee_name",      :limit => 128
      t.string   "last_name",          :limit => 64
      t.string   "company",            :limit => 64
      t.string   "address1",           :limit => 64
      t.string   "address2",           :limit => 64
      t.string   "city",               :limit => 64
      t.string   "state",              :limit => 64
      t.string   "zipcode",            :limit => 64
      t.string   "country",            :limit => 2,                                   :default => "",  :null => false
      t.string   "payment_type",       :limit => 16
      t.string   "ccnum",              :limit => 32
      t.text     "comment"
      t.integer  "failure_code"
      t.string   "failure_reason"
      t.string   "transaction_number", :limit => 64
      t.string   "currency",           :limit => 3
      t.decimal  "currency_rate",                     :precision => 12, :scale => 10, :default => 1.0
      t.decimal  "total",                             :precision => 10, :scale => 2,                   :null => false
      t.string   "uuid",               :limit => 36
    end

    add_index "orders", ["coupon_id"], :name => "coupon_id"
    add_index "orders", ["email"], :name => "email"

    create_table "products", :force => true do |t|
      t.string  "code",               :limit => 16,                                :default => "",  :null => false
      t.string  "name",               :limit => 64,                                :default => "",  :null => false
      t.decimal "price",                            :precision => 10, :scale => 2, :default => 0.0, :null => false
      t.text    "image_path"
      t.text    "url"
      t.text    "download_url"
      t.text    "license_url_scheme"
      t.integer "active",                                                          :default => 1,   :null => false
    end

    create_table "regional_prices", :force => true do |t|
      t.string   "currency",       :limit => 3,                                                 :null => false
      t.decimal  "amount",                      :precision => 10, :scale => 2, :default => 0.0, :null => false
      t.integer  "container_id"
      t.string   "container_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "sessions", :force => true do |t|
      t.string   "session_id", :null => false
      t.text     "data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"
  end
end
