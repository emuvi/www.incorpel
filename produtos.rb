require 'pg'

uri = URI.parse(ENV['LINK_WEBSITE_INCORPEL'])
link = PG.connect :host => uri.hostname, :port => uri.port, :dbname => uri.path[1..-1], :user => uri.user, :password => uri.password

origin = File.read("produtos.html")
begin_token = '<!-- BEGIN PRODUTOS -->'
end_token = '<!-- END PRODUTOS -->'
begin_zone = origin.index(begin_token) + begin_token.length()
end_zone = origin.index(end_token, begin_zone)
File.open("produtos-new.html", "w") do |f|
  f.write(origin[0..begin_zone])
  
  grupos = link.exec "SELECT * FROM grupos_produtos WHERE ativo = 'S' ORDER BY codigo"
  grupos.each do |grupo|
    puts "Grupo: " + grupo['codigo']
    f.write "<h3>"
    f.write grupo['nome']
    f.write "</h3>"
    f.write "\n"
    subgrupos = link.exec "SELECT * FROM subgrupos_produtos WHERE ativo = 'S' AND grupo = '" + grupo['codigo'] + "' ORDER BY nome"
    subgrupos.each do |subgrupo|
      puts "SubGrupo: " + subgrupo['codigo']
      f.write "<div>"
      f.write "\n"
      f.write "<h4 onclick='toggleSubGrupo(this)'>"
      f.write subgrupo['nome']
      f.write "</h4>"
      f.write "\n"
      f.write "<ul class='display-none'>"
      f.write "\n"
      produtos = link.exec "SELECT * FROM produtos WHERE ativo = 'S' AND grupo = '" + grupo['codigo'] + "' AND subgrupo = '" + subgrupo['codigo'] + "' ORDER BY ordem"
      produtos.each do |produto|
        puts "Produto: " + produto['codigo']
        f.write "<li>"
        f.write produto['nome']
        f.write "</li>"
        f.write "\n"
      end
      f.write "</ul>"
      f.write "\n"
      f.write "</div>"
      f.write "\n"
    end
  end

  f.write(origin[end_zone..-1])
end

File.delete("produtos.html")
File.rename("produtos-new.html", "produtos.html")

puts "Finished making produtos.html"
