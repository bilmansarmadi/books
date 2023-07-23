class UsersController < ApplicationController
    require 'digest'
    def users
      users_email = params[:email]
      trigger = params[:trigger]
      triggerdetail = params[:triggerdetail]
      users_password = params[:password]
      users_name = params[:users_name]
      users_id = params[:users_id]
  
      db_connection = ActiveRecord::Base.connection
  
      if trigger == 'R'
        if triggerdetail == 'Login'
        result = Read(users_email, users_password, db_connection)
        elsif triggerdetail == 'Account'
            result = Account(users_id, users_email, users_password, db_connection)
        else
            render json: { Status: 1002, Data: [], Error: "", Message: "Invalid trigger detail" }    
        end
      elsif trigger == 'C'
        result = Create(users_name, users_email, users_password, db_connection)
      else
        render json: { Status: 1002, Data: [], Error: "", Message: "Invalid trigger" }
      end
    end
  
    def Read(users_email, users_password, db_connection)

      encrypted_password = Digest::MD5.hexdigest(users_password)
      result = db_connection.execute("SELECT * FROM m_users WHERE users_email = '#{users_email}' AND users_password = '#{encrypted_password}'")
  
      if result.any?
        user = result.first
       user_id = user[0]
        username = user[1]
        email = user[2]
        render json: { Status: 1000, Data: [{users_id: user_id, username: username, emial:email }], Error: "", Message: "Success" }, status: :ok
      else
        render json: { Status: 1001, Data: [], Error: "", Message: "Invalid email or password" }
      end
    end

    def Account(users_id, users_email, users_password, db_connection)
      param = AdvSqlParamGeneratorMiddleware.new(nil).send(:AdvSqlParamGenerator, [{
        'Table' => '',
        'Field' => 'users_id',
        'Value' => users_id,
        'Syntax' => '='
      },
      {
        'Table' => '',
        'Field' => 'users_email',
        'Value' => "'#{users_email}'",
        'Syntax' => '='
      }])
    
      encrypted_password = Digest::MD5.hexdigest(users_password)
      result = db_connection.execute("SELECT * FROM m_users WHERE 1 = 1 #{param}")
    
      if result.any?
        user = result.first
        data = {
          users_id: user[0],
          users_name: user[1],
          users_email: user[2],
          users_password: user[3],
          locations: user[4],
          balance: user[5]
        }
        render json: { Status: 1000, Data: [data], Error: "", Message: "Your Account" }, status: :ok
      else
        render json: { Status: 1001, Data: [], Error: "", Message: "Invalid email or password" }
      end
    end
    
    def Create(users_name, users_email, users_password, db_connection)
      
        encrypted_password = Digest::MD5.hexdigest(users_password)
        query = "INSERT INTO m_users (users_name, users_email, users_password) VALUES ('#{users_name}', '#{users_email}', '#{encrypted_password}')"
        if db_connection.insert(query) # Jika query berhasil dijalankan
            render json: { Status: 1000, Data: [], Error: "", Message: "Create successful" }
        else
            render json: { Status: 1004, Data: [], Error: "", Message: "Create failed" }
        end
      end
      
  

    end
  