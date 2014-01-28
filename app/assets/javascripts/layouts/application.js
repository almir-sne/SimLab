function alterar_role(obj)
{
    $.ajax(
        {
            url: alt_role,
            data: {id: userid ,r: $(obj).val()}
        }
    ).always(
        function (data)
        {
            location.reload(true);
            alert("Role do usuário atual foi alterada!");
        }
    );
}