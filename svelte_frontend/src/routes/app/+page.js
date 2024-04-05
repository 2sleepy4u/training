import { redirect } from '@sveltejs/kit';
try {
    redirect(302, "/app/list")
} catch(e) {
    console.error(e)
}


