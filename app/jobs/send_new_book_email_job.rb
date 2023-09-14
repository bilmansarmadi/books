class SendNewBookEmailJob
  include Sidekiq::Worker

  def perform(email, book_id)
    BookMailer.new_book_email(email, book_id).deliver_now
  end
end
