function alterar_role(obj)
{
    $.ajax(
     {
        url: alt_role,
        data: {id: userid ,r: $(obj).val()}
     }
).done();
}