class AdvSqlParamGeneratorMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.path.start_with?('/users') && request.get?
      # Ambil parameter dari query string atau request body
      data = request.params['data']

      # Panggil fungsi AdvSqlParamGenerator dan simpan hasilnya dalam variabel qry
      qry = AdvSqlParamGenerator(data)

      # Tambahkan qry ke query string atau request body jika diperlukan
      # Misalnya, jika menggunakan query string:
      # request.env['QUERY_STRING'] = "#{request.env['QUERY_STRING']}&#{qry}"
      # Atau jika menggunakan request body dalam format JSON:
      # request.body = { data: qry }.to_json

      # Lanjutkan pemrosesan ke aplikasi Rails dengan menyediakan argumen env
      return @app.call(env) if qry.empty?

      env['QUERY_STRING'] = "#{env['QUERY_STRING']}&#{qry}"
    end

    # Lanjutkan pemrosesan ke aplikasi Rails dengan menyediakan argumen env
    @app.call(env)
  end

  private

  def AdvSqlParamGenerator(data)
    # Implementasikan logika fungsi AdvSqlParamGenerator di sini
    # Sesuaikan dengan struktur data yang Anda inginkan

    # Contoh implementasi sederhana:
    result = ''
    data.each do |item|
      table = item['Table']
      field = item['Field']
      value = item['Value']
      syntax = item['Syntax']
      ndValue = item['ndValue']

      unless table.nil? && (value.nil? || value.empty?) && syntax.nil?
        temp_val = value
        operator = 'AND'
        key = ''
        
        if syntax == 'BETWEEN'
          if ndValue.nil? || ndValue.empty?
            anValue = value
          end
          
          if value.nil? || value.empty?
            value = ndValue
          end
          temp_val = "'#{value}' AND '#{ndValue}'"
        elsif syntax == 'IN'
          temp_val = "(#{value})"
        end
        unless (value.nil? || value.empty?)   
        key = table.nil? || table.empty? ? field : "#{table}.#{field}"
        result += " #{operator} #{key} #{syntax} #{temp_val}"
        end
      end
      
    end

    result
  end
end

