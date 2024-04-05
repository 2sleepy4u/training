<script>
    import { goto } from "$app/navigation";
    import { getPostFetchOptions } from "$lib/index.js";

    async function Login() {
        try {
            //request SSID
            //await fetch(endpoints.get_new_session, {method: "POST"})
            await fetch("http://192.168.0.149:8080/test", getPostFetchOptions())
            //refresh page, if SSID is valid then it will redirect to daily list
            goto("/")
        } catch(e) { 
            alert("Errore nel login")
        }

    }
</script>

<div id="loginForm">
    <input placeholder="email" type="email">
    <input placeholder="password" type="password">
    <button on:click={Login}>Log In</button>
</div>


<style>

    #loginForm input {
        display: block;
    }

    #loginForm {
        text-align: center;
    }
</style>
