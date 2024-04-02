import { redirect } from '@sveltejs/kit';

/** @type {import('./$types').LayoutServerLoad} */
export async function load({ cookies }) {
	const ssid = cookies.get('SSID');
    //check if SSID is valid for DB
    if(!ssid)
        redirect(302, '/login');
	return {
        ssid
	};
}
