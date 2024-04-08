<script>
    import { goto } from "$app/navigation";
    import { endpoints, getPostFetchOptions } from "$lib/index.js";

    let email;
    let password;

    async function Login() {
        try {
            //request SSID
            await fetch(endpoints.get_new_session, getPostFetchOptions({email, password}))
            //refresh page, if SSID is valid then it will redirect to daily list
            goto("/")
        } catch(e) { 
            alert("Errore nel login")
        }

    }
</script>

<div id="loginForm">
    <input placeholder="email" type="email" bind:value={email}>
    <input placeholder="password" type="password" bind:value={password}>
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
