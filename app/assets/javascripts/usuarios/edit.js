  $(document).ready(function() {
    $('.cpf').mask('000.000.000-00', {reverse: true});
    $('.telefone').mask('00009-0000', {reverse: true});
    $('.ddd').mask('00');
    $('.rg').mask('000.000.000-A', {reverse: true});
    $('.conta').mask('000.000-A', {reverse: true});
    $('.agencia').mask('0000-9');
    $('.dinheiro').mask('000.00', {reverse: true});
    $('.cep').mask('00000-000');
    });