import pandas as pd
from tqdm import tqdm

input_file = r"D:\try\MySQL\UserBehavior.csv"
output_file = r"D:\try\MySQL\UserBehavior_processed.csv"

chunksize = 500000

# 时间边界（避免字符串比较）
start = pd.Timestamp('2017-11-25')
end = pd.Timestamp('2017-12-03 23:59:59')

# dtype优化（减少内存 & 提速）
dtype = {
    0: 'int32',   # user_id
    1: 'int32',   # item_id
    2: 'int32',   # category_id
    3: 'category',# behavior
    4: 'int64'    # timestamp
}

reader = pd.read_csv(
    input_file,
    header=None,
    chunksize=chunksize,
    dtype=dtype
)

first_write = True

for chunk in tqdm(reader, desc="Processing", unit="chunk"):

    chunk.columns = ['user_id', 'item_id', 'category_id', 'behavior', 'timestamp']

    # 去空
    chunk.dropna(inplace=True)

    # 时间转换（只做一次）
    chunk['datetimes'] = pd.to_datetime(chunk['timestamp'], unit='s')

    # 时间过滤（使用Timestamp，避免隐式类型转换）
    chunk = chunk[(chunk['datetimes'] >= start) & (chunk['datetimes'] <= end)]

    # 时间拆分（向量化）
    dt = chunk['datetimes'].dt
    chunk['dates'] = dt.date
    chunk['times'] = dt.time
    chunk['hours'] = dt.hour

    # 去重（inplace减少内存拷贝）
    chunk.drop_duplicates(
        subset=['user_id', 'item_id', 'timestamp'],
        inplace=True
    )

    # 写出优化：一次性写header
    chunk.to_csv(
        output_file,
        mode='w' if first_write else 'a',
        header=first_write,
        index=False
    )

    first_write = False

print("数据预处理完成！")