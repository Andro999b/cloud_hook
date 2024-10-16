use core::slice;

#[no_mangle]
pub extern "C" fn search(
    size: usize,
    data: *const u8, 
    callback: unsafe extern "C" fn(usize, *const u8)
) {
    let bytes = unsafe {
        slice::from_raw_parts(data, size)
    };

    let nums = Vec::from(bytes);
    println!("{:?}", nums);

    let res: Vec<u8> = vec![1u8, 2, 3, 4, 5];
    let ptr = res.as_ptr() as *mut u8;
    let _box = Box::new(bytes);

    unsafe {
        callback(res.len(), ptr);
    }    
}