# apinfe
Api para emissao de Nota e Autorização de NFe

Por um aplicativo mobile que faz pedidos on-line poderemos efetuar as seguintes operações
  1. Faturamento - Gera o faturamento do numero do pedido informado.
        O faturamento acontece usando base de dados em mysql com estrutura própria.
        
  2. Autorização - Gera o XML e envia para autorização 
        A autorização monta o xml, valida e envia utilizando os componentes do ACBR https://projetoacbr.com.br/
        
  3. EnviaEmail - Envia o xml e pdf para email cadastrado no cliente.
        
