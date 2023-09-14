class BooksController < ApplicationController
  require 'digest'
  require 'will_paginate/array'
      def books
        trigger = params[:trigger]
        page = params[:page]
        per_page = params[:per_page]
        triggerdetail = params[:triggerdetail]
        book_name = params[:book_name]
        authors_id = params[:authors_id]
        authors_name = params[:authors_name]
        book_id = params[:book_id]
        users_id = params[:users_id]
        book_content = params[:book_content]
        tahun_terbit = params[:tahun_terbit]
        
        db_connection = ActiveRecord::Base.connection

        if trigger == 'R'
          result = Read(book_name,authors_id,book_id,authors_name,tahun_terbit,page,per_page)
        elsif trigger == 'C'
          result = Create(book_name,authors_id,book_content,users_id,tahun_terbit)
        elsif trigger == 'U'
          result = Update(book_name,authors_id,book_id,book_content,tahun_terbit)
        elsif trigger == 'D'
          result = Delete(book_id)  
        else
          render json: { Status: 1002, Data: [], Error: "", Message: "Invalid trigger" }
        end
      end

      def Read(book_name, authors_id, book_id, authors_name,tahun_terbit,page,per_page)
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
            },
            {
              'Table' => 'books',
              'Field' => 'book_name',
              'Value' => book_name.present? ? "'%#{book_name}%'" : nil,
              'Syntax' => 'LIKE'
            },
            {
              'Table' => 'books',
              'Field' => 'book_id',
              'Value' => book_id.present? ? "'#{book_id}'" : nil,
              'Syntax' => '='
            },
            {
              'Table' => 'books',
              'Field' => 'tahun_terbit',
              'Value' => tahun_terbit.present? ? "'#{tahun_terbit}'" : nil,
              'Syntax' => '='
            }
          ])
          param = "1 = 1 #{param}"

          total_count = Book.joins(:author).where(param).count

          page = params[:page] || page
          per_page = params[:per_page] || per_page
          
          books = Book.joins(:author)
            .select('books.*, authors.authors_name') # Ganti 'name' dengan kolom yang sesuai di tabel authors
            .where(param)
            .paginate(page: page, per_page: per_page)

          
          if books.any?
            render json: {
              Status: 1000,
              Data: books,
              Total: total_count, 
              Error: "",
              Message: "Success"
            }, status: :ok
          else
            render json: {
              Status: 1001,
              Data: [],
              Total: total_count, 
              Error: "",
              Message: "Data Not Found"
            }
          end
      end
      
      def Create(book_name, authors_id, book_content, users_id,tahun_terbit)
        user = User.find_by(users_id: users_id)
      
        if user.present?
          @book = Book.new(book_name: book_name, author_id: authors_id, book_content: book_content, tahun_terbit:tahun_terbit)
      
          if @book.save # Jika query berhasil dijalankan
            SendNewBookEmailJob.perform_async(user.email, @book.book_id)
            render json: { Status: 1000, Data: [], Error: "", Message: "Create successful" }
          else
            render json: { Status: 1004, Data: [], Error: @book.errors.full_messages.join(', '), Message: "Create failed" }
          end
        else
          render json: { Status: 1004, Data: [], Error: "User not found", Message: "Create failed" }
        end
      end
      

        def Update(book_name,authors_id,book_id,book_content,tahun_terbit)
          books = Book.find_by(book_id: book_id) # Asumsi authors_id adalah parameter yang Anda terima
          if books
            if books.update(book_name: book_name, author_id: authors_id, book_content:book_content,tahun_terbit:tahun_terbit)
              render json: { Status: 1000, Data: [], Error: "", Message: "Update successful" }
            else
              render json: { Status: 1004, Data: [], Error: books.errors.full_messages.join(', '), Message: "Update failed" }
            end
          else
            render json: { Status: 1005, Data: [], Error: "", Message: "book not found" }
          end
        end
        
        def Delete(book_id)
          books = Book.find_by(book_id: book_id) 
          if books
            if books.destroy
              render json: { Status: 1000, Data: [], Error: "", Message: "Delete successful" }
            else
              render json: { Status: 1004, Data: [], Error: book.errors.full_messages.join(', '), Message: "Delete failed" }
            end
          else
            render json: { Status: 1005, Data: [], Error: "", Message: "book not found" }
          end
      end
  end
  