class BookMailer < ApplicationMailer

    default from: 'notifications@example.com' # alamat email pengirim default
  
    def new_book_email(email, book_id)
      @book = Book.find(book_id)
      mail(to: email, subject: 'Buku Baru Telah Ditambahkan')
    end
  
  end
  