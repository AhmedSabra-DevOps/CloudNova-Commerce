import axiosClient, { cartUrl } from "./config"

const CUSTOMER_ID = "john@example.com";

const addToCart = async (item: any) => {
    try {
        const currentCart = await getCart();
        const existingItems = currentCart?.items || [];
        
        const existingItem = existingItems.find((i: any) => i.sku === item?.sku);
        let newItems;

        if (existingItem) {
            newItems = existingItems.map((i: any) => 
                i.sku === item?.sku 
                    ? { ...i, quantity: i.quantity + item?.quantity }
                    : i
            );
        } else {
            newItems = [...existingItems, {
                productId: item?.productId,
                sku: item?.sku,
                title: item?.title,
                quantity: item?.quantity,
                price: parseFloat(item?.price),
                currency: item?.currency
            }];
        }

        const response = await axiosClient.post(cartUrl + 'cart', {
            customerId: CUSTOMER_ID,
            items: newItems
        });

        window.dispatchEvent(new Event("cartUpdated"));
        return response.data;
    } catch (err: any) {
        console.log(err);
    }
}

export const getCart = async () => {
    try {
        const response = await axiosClient.get(cartUrl + 'cart/' + CUSTOMER_ID);
        return response.data;
    } catch (err: any) {
        console.log(err);
        return { items: [], total: 0 };
    }
}

export const clearCart = async () => {
    try {
        const response = await axiosClient.delete(cartUrl + 'cart/' + CUSTOMER_ID);
        window.dispatchEvent(new Event("cartUpdated"));
        return response.data;
    } catch (err: any) {
        console.log(err);
        throw err;
    }
}

export default addToCart
