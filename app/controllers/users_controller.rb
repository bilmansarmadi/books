class UsersController < ApplicationController
    require 'digest'
    def users
      users_email = params[:email]
      trigger = params[:trigger]
      triggerdetail = params[:triggerdetail]
      users_password = params[:password]
      users_name = params[:users_name]
      users_id = params[:users_id]
      level = params[:level]
  
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
        result = Create(users_name, users_email, users_password, level)
      elsif trigger == 'U'
        result = Update(users_name, users_email, users_password,users_id, level)
      elsif trigger == 'D'
        result = Delete(users_id)  
      else
        render json: { Status: 1002, Data: [], Error: "", Message: "Invalid trigger" }
      end
    end
  
    def Read(users_email, users_password, db_connection)
      
      user = User.find_by(email:users_email, password:Digest::MD5.hexdigest(users_password))
      # result = db_connection.execute("SELECT * FROM m_users WHERE users_email = '#{users_email}' AND users_password = '#{encrypted_password}'")
      if user
        render json: { Status: 1000, Data: [{users_id: user.users_id, users_name: user.username, emial:user.email, level:user.level }], Error: "", Message: "Success" }, status: :ok
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
    
    def Create(users_name, users_email, users_password, level)
      
      encrypted_password = Digest::MD5.hexdigest(users_password)

        user = User.new(email: users_email, username: users_name, password: encrypted_password,level: level)
        if user.save # Jika query berhasil dijalankan
          render json: { Status: 1000, Data: [], Error: "", Message: "Create successful" }
        else
          render json: { Status: 1004, Data: [], Error: user.errors.full_messages.join(', '), Message: "Create failed" }
        end
      end

      def Update(users_name, users_email, users_password,users_id, level)
        user = User.find_by(users_id: users_id) # Asumsi user_id adalah parameter yang Anda terima
        if user
          if user.update(email: users_email, username: users_name, level: level)
            render json: { Status: 1000, Data: [], Error: "", Message: "Update successful" }
          else
            render json: { Status: 1004, Data: [], Error: user.errors.full_messages.join(', '), Message: "Update failed" }
          end
        else
          render json: { Status: 1005, Data: [], Error: "", Message: "User not found" }
        end
      end

      def Delete(users_id)
        user = User.find_by(users_id: users_id) # Asumsi users_id adalah parameter yang Anda terima
        if user
          if user.destroy
            render json: { Status: 1000, Data: [], Error: "", Message: "Delete successful" }
          else
            render json: { Status: 1004, Data: [], Error: user.errors.full_messages.join(', '), Message: "Delete failed" }
          end
        else
          render json: { Status: 1005, Data: [], Error: "", Message: "User not found" }
        end
      end
      
  

    end
  