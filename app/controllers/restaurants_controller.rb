class RestaurantsController < ApplicationController
    require 'digest'
    def restaurants
        restaurants_name = params[:restaurants_name].to_s
        menu_name = params[:menu_name].to_s
        restaurants_location = params[:restaurants_location].to_s
        restaurants_balance = params[:triggerdetail].to_s
        restaurants_hours = params[:restaurants_hours].to_s
        restaurants_hours_01 = params[:restaurants_hours_01].to_s
        restaurants_hours_02 = params[:restaurants_hours_02].to_s
        menu_price_01 = params[:menu_price_01].to_s
        menu_price_02 = params[:menu_price_02].to_s
        restaurants_day = params[:restaurants_day].to_s
        location_users = params[:location_users].to_s
        restaurants_id = params[:restaurants_id]
        purchases_id = params[:purchases_id]
        menu_id = params[:menu_id]
        users_id = params[:users_id]
        trigger = params[:trigger].to_s
        triggerdetail = params[:triggerdetail].to_s
        date_01 = params[:date_01].to_s
        date_02 = params[:date_02].to_s
        transaction_totals_01 = params[:transaction_totals_01].to_s
        transaction_totals_02 = params[:transaction_totals_02].to_s
        users_name = params[:users_name].to_s
        triggerdetail = params[:triggerdetail].to_s
        orderby_opening_hours = params[:orderby_opening_hours].to_s
        orderby_menu_price = params[:orderby_menu_price].to_s
        orderby_distance = params[:orderby_distance].to_s 
        orderby_total_transactions = params[:orderby_total_transactions].to_s
        orderby_total_money = params[:orderby_total_money].to_s 
        order_quantity = params[:order_quantity]
        
  
      db_connection = ActiveRecord::Base.connection
  
      if trigger == 'R'
        if triggerdetail == 'list_of_restaurants'
        result = Read(restaurants_name, restaurants_location, restaurants_balance, restaurants_hours, restaurants_id, restaurants_day, restaurants_hours_01, restaurants_hours_02,location_users,menu_name,menu_price_01,menu_price_02,orderby_distance, orderby_opening_hours, db_connection)
        elsif triggerdetail == ' user_transaction_summary'
        result =  user_transaction_summary(restaurants_name, restaurants_location, restaurants_balance, restaurants_hours, restaurants_id, restaurants_day, restaurants_hours_01, restaurants_hours_02,location_users,menu_name,menu_price_01,menu_price_02,orderby_distance,orderby_menu_price, orderby_opening_hours, date_01, date_02,users_name,transaction_totals_01,transaction_totals_02, db_connection)
        elsif triggerdetail == 'restaurants_transaction_summary'
          result = restaurants_transaction_summary(restaurants_name, restaurants_location, restaurants_balance, restaurants_hours, restaurants_id, restaurants_day, restaurants_hours_01, restaurants_hours_02,location_users,menu_name,menu_price_01,menu_price_02,orderby_total_transactions, orderby_total_money,date_01,date_02, db_connection) 
        elsif triggerdetail == 'detail_transaction'
          result = detail_transaction(restaurants_name, restaurants_id,menu_name,menu_id,date_01,date_02,users_name,users_id, db_connection)   
        else
            render json: { Status: 1002, Data: [], Error: "", Message: "Invalid trigger detail" }    
        end
      elsif trigger == 'C'
        result = Create(users_id, menu_id, restaurants_id,order_quantity, db_connection)
      elsif trigger == 'D'
        result = Delete(purchases_id,db_connection)
      else
        render json: { Status: 1002, Data: [], Error: "", Message: "Invalid trigger" }
      end
    end
  
    def Read(restaurants_name, restaurants_location, restaurants_balance, restaurants_hours, restaurants_id, restaurants_day, restaurants_hours_01, restaurants_hours_02,location_users,menu_name,menu_price_01,menu_price_02,orderby_distance,orderby_opening_hours, db_connection)
        param = AdvSqlParamGeneratorMiddleware.new(nil).send(:AdvSqlParamGenerator, [{
          'Table' => 'restaurants',
          'Field' => 'restaurants_id',
          'Value' => restaurants_id,
          'Syntax' => '='
        },
        {
            'Table' => 'restaurants',
            'Field' => 'restaurants_name',
            'Value' => restaurants_name.present? ? "'%#{restaurants_name}%'" : nil,
            'Syntax' => 'LIKE'
        },
        {
            'Table' => 'restaurants_menu',
            'Field' => 'menu_name',
            'Value' => menu_name.present? ? "'%#{menu_name}%'" : nil,
            'Syntax' => 'LIKE'
        },
        {
            'Table' => 'restaurants_hours',
            'Field' => 'day',
            'Value' => restaurants_day.present? ? "'%#{restaurants_day}%'" : nil,
            'Syntax' => 'LIKE'
        }
        ])

        if restaurants_hours.present?
            paramcustome = " AND (TIME('#{restaurants_hours}') BETWEEN opening_hours AND closing_hours) "
            else
            paramcustome = nil
            end

        if restaurants_hours_01.present? && restaurants_hours_02.present?
        paramcustome_01 = " AND (restaurants_hours.opening_hours >= '#{restaurants_hours_01}' AND restaurants_hours.closing_hours <= '#{restaurants_hours_02}') "
        elsif restaurants_hours_01.present?
        paramcustome_01 = " AND (restaurants_hours.opening_hours >= '#{restaurants_hours_01}')"
        elsif restaurants_hours_02.present?
        paramcustome_01 = " AND (restaurants_hours.closing_hours <= '#{restaurants_hours_02}')"
        else
        paramcustome_01 = nil    
        end  

        if menu_price_01.present? && menu_price_01.present?
        paramcustome_02 = " AND (menu_price >= '#{menu_price_01}' AND menu_price <= '#{menu_price_02}') "
        elsif menu_price_01.present?
        paramcustome_02 = " AND (menu_price >= '#{menu_price_01}')"
        elsif menu_price_02.present?
        paramcustome_02 = " AND (menu_price <= '#{menu_price_02}')"
        else
        paramcustome_02 = nil    
        end  

        if orderby_distance == '1' && orderby_opening_hours == '2'
            order_by = "distance + 0, restaurants_hours.opening_hours"
          elsif orderby_opening_hours == '1' && orderby_distance == '2'
            order_by = "restaurants_hours.opening_hours, distance + 0"
          else
            order_by = "distance + 0, restaurants_hours.opening_hours" # Default order
          end
          

          result = db_connection.execute("
          SELECT
            restaurants.restaurants_id,
            restaurants.restaurants_location,
            restaurants.restaurants_balance,
            restaurants.restaurants_name,
            GROUP_CONCAT(CONCAT(restaurants_hours.day, ' ',
              TIME_FORMAT(restaurants_hours.opening_hours, '%h:%i %p'), ' - ',
              TIME_FORMAT(restaurants_hours.closing_hours, '%h:%i %p'),' ')) AS open_time,
            GROUP_CONCAT(CONCAT(menu_name, ' $', menu_price)) AS menu_list,
            CONCAT(distance(restaurants.restaurants_id, #{location_users}), ' km') AS distance
          FROM
            restaurants
          INNER JOIN
            restaurants_hours ON restaurants_hours.restaurants_id = restaurants.restaurants_id
          INNER JOIN
            restaurants_menu ON restaurants_menu.restaurants_id = restaurants.restaurants_id 
          WHERE 1 = 1 #{paramcustome} #{paramcustome_02} #{paramcustome_01} #{param}
          GROUP BY
            restaurants.restaurants_id,
            restaurants.restaurants_location,
            restaurants.restaurants_balance,
            restaurants.restaurants_name
          ORDER BY
            #{order_by}
        ")
      
        if result.any?
          data = result.to_a.map do |row|
            row.each_with_index.each_with_object({}) do |(value, index), hash|
              field_name = result.fields[index]
              hash[field_name.to_sym] = value
            end
          end
          render json: { Status: 1000, Data: data, Error: "", Message: "Your Account" }, status: :ok
        else
          render json: { Status: 1001, Data: [], Error: "", Message: "Invalid email or password" }
        end
      end
      
      

      def  user_transaction_summary(restaurants_name, restaurants_location, restaurants_balance, restaurants_hours, restaurants_id, restaurants_day, restaurants_hours_01, restaurants_hours_02,location_users,menu_name,menu_price_01,menu_price_02,orderby_distance,orderby_menu_price,orderby_opening_hours,date_01,date_02,users_name,transaction_totals_01,transaction_totals_02, db_connection)
        
       
        param = AdvSqlParamGeneratorMiddleware.new(nil).send(:AdvSqlParamGenerator, [{
          'Table' => 'restaurants',
          'Field' => 'restaurants_id',
          'Value' => restaurants_id,
          'Syntax' => '='
        },
        {
            'Table' => 'restaurants',
            'Field' => 'restaurants_name',
            'Value' => restaurants_name.present? ? "'%#{restaurants_name}%'" : nil,
            'Syntax' => 'LIKE'
        },
        {
            'Table' => 'restaurants_menu',
            'Field' => 'menu_name',
            'Value' => menu_name.present? ? "'%#{menu_name}%'" : nil,
            'Syntax' => 'LIKE'
        },
        {
            'Table' => 'm_users',
            'Field' => 'users_name',
            'Value' => users_name.present? ? "'%#{users_name}%'" : nil,
            'Syntax' => 'LIKE'
        },
        {
            'Table' => '',
            'Field' => 'DATE(purchases_date)',
            'Value' => date_01.present? ? "#{date_01}" : nil,
            'ndValue' => date_02.present? ? "#{date_02}" : nil,
            'Syntax' => 'BETWEEN'
        },
        {
            'Table' => '',
            'Field' => 'total_transactions',
            'Value' => transaction_totals_01.present? ? "#{transaction_totals_01}" : nil,
            'ndValue' => transaction_totals_02.present? ? "#{transaction_totals_02}" : nil,
            'Syntax' => 'BETWEEN'
        }
        ])

          result = db_connection.execute("
          SELECT
          m_users.users_id,
          m_users.users_name,
          COUNT(purchases.purchases_id) AS total_transactions,
          IF(SUM(restaurants_menu.menu_price * purchases.order_quantity) MOD 1 = 0,
          TRUNCATE(SUM(restaurants_menu.menu_price * purchases.order_quantity), 0),
          TRUNCATE(SUM(restaurants_menu.menu_price * purchases.order_quantity), 2)) AS total
          
        FROM
          m_users 
        INNER JOIN
          purchases ON purchases.user_id = m_users.users_id
        INNER JOIN
          restaurants_menu ON restaurants_menu.menu_id = purchases.menu_id
        INNER JOIN
          restaurants ON restaurants.restaurants_id = restaurants_menu.restaurants_id
        INNER JOIN 
        user_transaction_summary on user_transaction_summary.users_id = m_users.users_id
          WHERE 1 = 1 #{param}
          GROUP BY
          m_users.users_id,
          m_users.users_name
        ORDER BY
          total_transactions DESC,
          total DESC
        ")
      
        if result.any?
          data = result.to_a.map do |row|
            row.each_with_index.each_with_object({}) do |(value, index), hash|
              field_name = result.fields[index]
              hash[field_name.to_sym] = value
            end
          end
          render json: { Status: 1000, Data: data, Error: "", Message: "Your Account" }, status: :ok
        else
          render json: { Status: 1001, Data: [], Error: "", Message: "Invalid email or password" }
        end
      end

      def restaurants_transaction_summary(restaurants_name, restaurants_location, restaurants_balance, restaurants_hours, restaurants_id, restaurants_day, restaurants_hours_01, restaurants_hours_02,location_users,menu_name,menu_price_01,menu_price_02,orderby_total_transactions,orderby_total_money,date_01,date_02, db_connection)
        param = AdvSqlParamGeneratorMiddleware.new(nil).send(:AdvSqlParamGenerator, [{
          'Table' => 'restaurants',
          'Field' => 'restaurants_id',
          'Value' => restaurants_id,
          'Syntax' => '='
        },
        {
            'Table' => 'restaurants',
            'Field' => 'restaurants_name',
            'Value' => restaurants_name.present? ? "'%#{restaurants_name}%'" : nil,
            'Syntax' => 'LIKE'
        },
        {
            'Table' => '',
            'Field' => 'DATE(purchases_date)',
            'Value' => date_01.present? ? "#{date_01}" : nil,
            'ndValue' => date_02.present? ? "#{date_02}" : nil,
            'Syntax' => 'BETWEEN'
        }
        ])

        if orderby_total_transactions == '1' && orderby_total_money == '2'
            order_by = "total_transactions DESC, total DESC"
          elsif orderby_total_money == '1' && orderby_total_transactions == '2'
            order_by = "total DESC, total_transactions DESC"
          else
            order_by = "total_transactions DESC, total DESC" # Default order
          end
          

          result = db_connection.execute("
          SELECT
          restaurants.restaurants_id,
          restaurants_name,
          COUNT(purchases_id) AS total_transactions,
          IF(SUM(restaurants_menu.menu_price * purchases.order_quantity) MOD 1 = 0,
          TRUNCATE(SUM(restaurants_menu.menu_price * purchases.order_quantity), 0),
          TRUNCATE(SUM(restaurants_menu.menu_price * purchases.order_quantity), 2)) AS total
          FROM
          restaurants
          INNER JOIN
          restaurants_menu ON restaurants_menu.restaurants_id = restaurants.restaurants_id
          INNER JOIN
          purchases ON purchases.menu_id = restaurants_menu.menu_id
          WHERE 1 = 1 #{param}
          GROUP BY
          restaurants.restaurants_id,
          restaurants_name
          ORDER BY
          #{order_by}
        ")
      
        if result.any?
          data = result.to_a.map do |row|
            row.each_with_index.each_with_object({}) do |(value, index), hash|
              field_name = result.fields[index]
              hash[field_name.to_sym] = value
            end
          end
          render json: { Status: 1000, Data: data, Error: "", Message: "Your Account" }, status: :ok
        else
          render json: { Status: 1001, Data: [], Error: "", Message: "Invalid email or password" }
        end
      end
    
      
      def detail_transaction(restaurants_name, restaurants_id,menu_name,menu_id,date_01,date_02,users_name,users_id, db_connection)
        param = AdvSqlParamGeneratorMiddleware.new(nil).send(:AdvSqlParamGenerator, [{
          'Table' => 'restaurants',
          'Field' => 'restaurants_id',
          'Value' => restaurants_id,
          'Syntax' => '='
        },{
          'Table' => 'purchases',
          'Field' => 'menu_id',
          'Value' => menu_id,
          'Syntax' => '='
        },{
          'Table' => 'm_users',
          'Field' => 'users_id',
          'Value' => users_id,
          'Syntax' => '='
        },
        {
            'Table' => 'restaurants',
            'Field' => 'restaurants_name',
            'Value' => restaurants_name.present? ? "'%#{restaurants_name}%'" : nil,
            'Syntax' => 'LIKE'
        },
        {
            'Table' => '',
            'Field' => 'DATE(purchases_date)',
            'Value' => date_01.present? ? "#{date_01}" : nil,
            'ndValue' => date_02.present? ? "#{date_02}" : nil,
            'Syntax' => 'BETWEEN'
        },
        {
            'Table' => 'm_users',
            'Field' => 'users_name',
            'Value' => users_name.present? ? "'%#{users_name}%'" : nil,
            'Syntax' => 'LIKE'
        },
        {
            'Table' => 'restaurants_menu',
            'Field' => 'menu_name',
            'Value' => menu_name.present? ? "'%#{menu_name}%'" : nil,
            'Syntax' => 'LIKE'
        }
        ])    

          result = db_connection.execute("
          SELECT
          purchases.purchases_id,
          restaurants.restaurants_id,
          restaurants_name,
          restaurants_menu.menu_name,
          m_users.users_id,
          m_users.users_name,
          restaurants_menu.menu_price,
          ROUND(SUM(restaurants_menu.menu_price * purchases.order_quantity), 2) AS total_payment,
          DATE_FORMAT(purchases_date, '%Y-%m-%d %h:%i %p') AS purchases_date,
          purchases.restaurants_balance as current_balance,
          purchases.user_balance as current_users
          FROM
          restaurants
          INNER JOIN
          restaurants_menu ON restaurants_menu.restaurants_id = restaurants.restaurants_id
          INNER JOIN
          purchases ON purchases.menu_id = restaurants_menu.menu_id
          INNER JOIN
          m_users ON m_users.users_id = purchases.user_id
          WHERE 1 = 1  #{param}
          GROUP BY
          purchases.purchases_id,
          restaurants.restaurants_id,
          restaurants_name,
          restaurants_menu.menu_name,
          m_users.users_id,
          m_users.users_name,
          restaurants_menu.menu_price,
          purchases_date,
          purchases.restaurants_balance,
          purchases.user_balance
      ORDER BY
          purchases_date DESC
        ")
      
        if result.any?
          data = result.to_a.map do |row|
            row.each_with_index.each_with_object({}) do |(value, index), hash|
              field_name = result.fields[index]
              hash[field_name.to_sym] = value
            end
          end
          render json: { Status: 1000, Data: data, Error: "", Message: "Your Account" }, status: :ok
        else
          render json: { Status: 1001, Data: [], Error: "", Message: "Invalid email or password" }
        end
      end

    def Create(users_id, menu_id, restaurants_id,order_quantity, db_connection)
        
      purchases_date = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        query = "INSERT INTO purchases (user_id, menu_id, restaurants_id, purchases_date,order_quantity) VALUES ('#{users_id}', '#{menu_id}', '#{restaurants_id}', '#{purchases_date}', '#{order_quantity}')"
        if db_connection.insert(query) # Jika query berhasil dijalankan
            render json: { Status: 1000, Data: [], Error: "", Message: "Create successful" }
        else
            render json: { Status: 1004, Data: [], Error: "", Message: "Create failed" }
        end
    end

    def Delete(purchases_id, db_connection)
        
        query = "DELETE FROM purchases where purchases_id = #{purchases_id}"
        if db_connection.insert(query) # Jika query berhasil dijalankan
            render json: { Status: 1000, Data: [], Error: "", Message: "DELETE successful" }
        else
            render json: { Status: 1004, Data: [], Error: "", Message: "DELETE failed" }
        end
    end
      
  

end
