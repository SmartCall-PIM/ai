# Script de diagnóstico da API na Azure

$azureUrl = "https://smartcall-gemini-api-bxdhg9embtc3b3f3.brazilsouth-01.azurewebsites.net"

Write-Host "=== Diagnóstico da API SmartCall na Azure ===" -ForegroundColor Cyan
Write-Host ""

# Teste 1: Verificar se o servidor está respondendo
Write-Host "1. Testando conexão com o servidor..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $azureUrl -Method Get -TimeoutSec 10
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Servidor está respondendo!" -ForegroundColor Green
} catch {
    Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "   Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
}
Write-Host ""

# Teste 2: Verificar a rota /docs (Swagger)
Write-Host "2. Testando rota /docs (Swagger)..." -ForegroundColor Yellow
try {
    $docsUrl = "$azureUrl/docs"
    $response = Invoke-WebRequest -Uri $docsUrl -Method Get -TimeoutSec 10
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Acesse: $docsUrl" -ForegroundColor Green
} catch {
    Write-Host "   Erro ao acessar /docs: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Teste 3: Verificar a rota /openapi.json
Write-Host "3. Testando rota /openapi.json..." -ForegroundColor Yellow
try {
    $openapiUrl = "$azureUrl/openapi.json"
    $response = Invoke-WebRequest -Uri $openapiUrl -Method Get -TimeoutSec 10
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "   Erro ao acessar /openapi.json: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Teste 4: Tentar POST na rota /analisar
Write-Host "4. Testando POST /analisar..." -ForegroundColor Yellow
try {
    $body = @{
        descricao = "Meu computador não liga. Quando aperto o botão de power, nada acontece."
    } | ConvertTo-Json

    $headers = @{
        "Content-Type" = "application/json"
    }

    $response = Invoke-RestMethod -Uri "$azureUrl/analisar" -Method Post -Body $body -Headers $headers -TimeoutSec 30
    
    Write-Host "   Sucesso! Resposta:" -ForegroundColor Green
    Write-Host "   Título: $($response.titulo)" -ForegroundColor Cyan
    Write-Host "   Categoria: $($response.categoria)" -ForegroundColor Cyan
    Write-Host "   Prioridade: $($response.prioridade)" -ForegroundColor Cyan
    Write-Host "   Sugestão: $($response.sugestao_solucao)" -ForegroundColor Cyan
} catch {
    Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Resposta do servidor: $responseBody" -ForegroundColor Red
    }
}
Write-Host ""

# Teste 5: Verificar logs do Azure (instruções)
Write-Host "=== Próximos passos ===" -ForegroundColor Cyan
Write-Host "Se os testes falharam, verifique:" -ForegroundColor Yellow
Write-Host "1. Os logs da aplicação no Portal Azure" -ForegroundColor White
Write-Host "2. Se o arquivo 'startup.txt' está configurado corretamente" -ForegroundColor White
Write-Host "3. Se as variáveis de ambiente estão definidas (GEMINI_API_KEY)" -ForegroundColor White
Write-Host "4. Se o Procfile ou configuração de inicialização está correta" -ForegroundColor White
Write-Host ""
Write-Host "Para ver os logs, execute:" -ForegroundColor Yellow
Write-Host "az webapp log tail --name smartcall-gemini-api-bxdhg9embtc3b3f3 --resource-group <seu-resource-group>" -ForegroundColor Cyan
