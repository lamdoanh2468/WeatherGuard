/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// 1. Cấu hình chính xác URL database của bạn (Server Asia)
admin.initializeApp({
  databaseURL: "https://dht11anddht22-14fb9-default-rtdb.asia-southeast1.firebasedatabase.app/"
});

// 2. Tên node chứa dữ liệu (như trong ảnh)
const DATABASE_PATH = 'sensor_data'; 
const KEEP_DAYS = 30; // Giữ lại 30 ngày (tùy chỉnh)

exports.autoDeleteOldData = functions.pubsub.schedule('every 24 hours')
    .timeZone('Asia/Ho_Chi_Minh')
    .onRun(async (context) => {
        const db = admin.database();
        const ref = db.ref(DATABASE_PATH);
        
        // Tính mốc thời gian
        const now = Date.now();
        const cutoff = now - (KEEP_DAYS * 24 * 60 * 60 * 1000); 

        // Query tìm dữ liệu cũ dựa trên 'timestamp'
        // LƯU Ý: Đảm bảo trong json của bạn có trường tên là 'timestamp'
        const oldItemsQuery = ref.orderByChild('timestamp').endAt(cutoff);

        try {
            const snapshot = await oldItemsQuery.once('value');
            
            if (!snapshot.exists()) {
                console.log("Database sạch sẽ, không có gì để xóa.");
                return null;
            }

            const updates = {};
            let count = 0;
            snapshot.forEach(child => {
                updates[child.key] = null;
                count++;
            });

            await ref.update(updates);
            console.log(`Đã xóa thành công ${count} dòng dữ liệu cũ.`);
        } catch (error) {
            console.error("Lỗi:", error);
        }
        return null;
    });