class AuthorsController < ApplicationController
    require 'digest'
    def authors
      trigger = params[:trigger]
      triggerdetail = params[:triggerdetail]
      authors_name = params[:authors_name]
      authors_id = params[:authors_id]
      
      db_connection = ActiveRecord::Base.connection
  
      if trigger == 'R'
        result = Read(authors_name,authors_id)
      elsif trigger == 'C'
        result = Create(authors_name)
      elsif trigger == 'U'
        result = Update(authors_name,authors_id)
      elsif trigger == 'D'
        result = Delete(authors_id)  
      else
        render json: { Status: 1002, Data: [], Error: "", Message: "Invalid trigger" }
      end
    end
  
    def Read(authors_name, authors_id)
      param = AdvSqlParamGeneratorMiddleware.new(nil).send(:AdvSqlParamGenerator, [
        {
            'Table' => 'authors',
            'Field' => 'authors_name',
            'Value' => authors_name.present? ? "'%#{authors_name}%'" : nil,
            'Syntax' => 'LIKE'
          },
          {
            'Table' => 'authors',
            'Field' => 'authors_id',
            'Value' => authors_id.present? ? "'#{authors_id}'" : nil,
            'Syntax' => '='
          }
        ])
        param = "1 = 1  #{param}"
      authors = Author.where(param)

      if authors.any?
        author_data = authors.map { |author| { authors_id: author.id, authors_name: author.authors_name } }
        render json: { Status: 1000, Data: author_data, Error: "", Message: "Success" }, status: :ok
      else
        render json: { Status: 1001, Data: [], Error: "", Message: "Data Not Found" }
      end
    end
    
    def Create(authors_name)
      
      authors = Author.new(authors_name: authors_name)
        if authors.save # Jika query berhasil dijalankan
          render json: { Status: 1000, Data: [], Error: "", Message: "Create successful" }
        else
          render json: { Status: 1004, Data: [], Error: authors.errors.full_messages.join(', '), Message: "Create failed" }
        end
      end

      def Update(authors_name, authors_id)
        authors = Author.find_by(authors_id: authors_id) # Asumsi authors_id adalah parameter yang Anda terima
        if authors
          if authors.update(authors_name: authors_name)
            render json: { Status: 1000, Data: [], Error: "", Message: "Update successful" }
          else
            render json: { Status: 1004, Data: [], Error: authors.errors.full_messages.join(', '), Message: "Update failed" }
          end
        else
          render json: { Status: 1005, Data: [], Error: "", Message: "authors not found" }
        end
      end

      def Delete(authors_id)
        authors = Author.find_by(authors_id: authors_id) # Asumsi authorss_id adalah parameter yang Anda terima
        if authors
          if authors.destroy
            render json: { Status: 1000, Data: [], Error: "", Message: "Delete successful" }
          else
            render json: { Status: 1004, Data: [], Error: authors.errors.full_messages.join(', '), Message: "Delete failed" }
          end
        else
          render json: { Status: 1005, Data: [], Error: "", Message: "authors not found" }
        end
    end

  end
  