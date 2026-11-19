-- Tiền dùng VND, thời hạn tính bằng ngày. NULL ở hạn cuối biểu thị đang hiệu lực.
-- Mức hoa hồng sản phẩm tính theo phần trăm, giảm giá là số tiền.
-- UNIQUE bổ sung: CCCD hội viên, mã tham chiếu trong cùng hình thức thanh toán.
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

CREATE TABLE dbo.CHI_NHANH (
    MaCN bigint NOT NULL,
    TenCN nvarchar(255) NOT NULL,
    DiaChi nvarchar(255) NOT NULL,
    SoDT varchar(25) NOT NULL,
    GioHoatDong nvarchar(255) NOT NULL,
    SucChua integer NOT NULL CHECK (SucChua > 0),
    PRIMARY KEY (MaCN)
);

CREATE TABLE dbo.SAN_PHAM (
    MaSP bigint NOT NULL,
    TenSP nvarchar(255) NOT NULL,
    LoaiSP nvarchar(255) NOT NULL,
    PRIMARY KEY (MaSP)
);

CREATE TABLE dbo.KINH_DOANH_SAN_PHAM (
    MaCN bigint NOT NULL,
    MaSP bigint NOT NULL,
    Gia numeric(16,2) NOT NULL CHECK (Gia >= 0),
    TrangThaiSP nvarchar(255) NOT NULL,
    PRIMARY KEY (MaCN, MaSP),
    FOREIGN KEY (MaCN) REFERENCES dbo.CHI_NHANH (MaCN),
    FOREIGN KEY (MaSP) REFERENCES dbo.SAN_PHAM (MaSP)
);

CREATE TABLE dbo.SP_CHINH_SACH_HOA_HONG (
    MaCN bigint NOT NULL,
    MaSP bigint NOT NULL,
    HieuLucTu date NOT NULL,
    HieuLucDen date NULL,
    MucHoaHong numeric(5,2) NOT NULL,
    PRIMARY KEY (MaCN, MaSP, HieuLucTu),
    FOREIGN KEY (MaCN,MaSP) REFERENCES dbo.KINH_DOANH_SAN_PHAM (MaCN,MaSP),
    CHECK (MucHoaHong BETWEEN 0 AND 100),
    CHECK (HieuLucDen IS NULL OR HieuLucDen >= HieuLucTu)
);

CREATE TABLE dbo.TON_KHO (
    MaCN bigint NOT NULL,
    MaSP bigint NOT NULL,
    SoLuongTon integer NOT NULL DEFAULT 0 CHECK (SoLuongTon >= 0),
    CapNhatLuc datetimeoffset(0) NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    PRIMARY KEY (MaCN, MaSP),
    FOREIGN KEY (MaCN,MaSP) REFERENCES dbo.KINH_DOANH_SAN_PHAM (MaCN,MaSP)
);

CREATE TABLE dbo.DICH_VU (
    MaDV bigint NOT NULL,
    TenDV nvarchar(255) NOT NULL,
    MoTa nvarchar(max) NULL,
    PRIMARY KEY (MaDV)
);

CREATE TABLE dbo.CHI_NHANH_DICH_VU (
    MaCN bigint NOT NULL,
    MaDV bigint NOT NULL,
    TrangThaiCungCap nvarchar(255) NOT NULL,
    PRIMARY KEY (MaCN, MaDV),
    FOREIGN KEY (MaCN) REFERENCES dbo.CHI_NHANH (MaCN),
    FOREIGN KEY (MaDV) REFERENCES dbo.DICH_VU (MaDV)
);

CREATE TABLE dbo.GOI_DICH_VU (
    MaGoi bigint NOT NULL,
    MaDV bigint NOT NULL,
    TenGoi nvarchar(255) NOT NULL,
    LoaiGoi nvarchar(255) NOT NULL,
    ThoiHan integer NOT NULL CHECK (ThoiHan > 0),
    SoLuotQD integer NULL CHECK (SoLuotQD > 0),
    Gia numeric(16,2) NOT NULL CHECK (Gia >= 0),
    PRIMARY KEY (MaGoi),
    FOREIGN KEY (MaDV) REFERENCES dbo.DICH_VU (MaDV)
);

CREATE TABLE dbo.HANG_HOI_VIEN (
    MaHang bigint NOT NULL,
    TenHang nvarchar(255) NOT NULL,
    NguongChiTieu12Th numeric(16,2) NOT NULL CHECK (NguongChiTieu12Th >= 0),
    PRIMARY KEY (MaHang)
);

CREATE TABLE dbo.HOI_VIEN (
    MaHV bigint NOT NULL,
    CCCD varchar(12) NOT NULL,
    HoTen nvarchar(255) NOT NULL,
    SoDT varchar(25) NOT NULL,
    Email nvarchar(255) NULL,
    NgaySinh date NOT NULL,
    GioiTinh nvarchar(255) NULL,
    NgayDangKy date NOT NULL DEFAULT (CONVERT(date, SYSDATETIME())),
    PRIMARY KEY (MaHV),
    UNIQUE (CCCD),
    CHECK (NgaySinh <= NgayDangKy)
);

CREATE TABLE dbo.LICH_SU_HANG (
    MaHV bigint NOT NULL,
    HieuLucTu date NOT NULL,
    MaHang bigint NOT NULL,
    HieuLucDen date NULL,
    ChiTieu12ThLucXet numeric(16,2) NOT NULL CHECK (ChiTieu12ThLucXet >= 0),
    PRIMARY KEY (MaHV, HieuLucTu),
    FOREIGN KEY (MaHV) REFERENCES dbo.HOI_VIEN (MaHV),
    FOREIGN KEY (MaHang) REFERENCES dbo.HANG_HOI_VIEN (MaHang),
    CHECK (HieuLucDen IS NULL OR HieuLucDen >= HieuLucTu)
);

CREATE TABLE dbo.NHAN_VIEN (
    MaNV bigint NOT NULL,
    HoTen nvarchar(255) NOT NULL,
    SoDT varchar(25) NOT NULL,
    ChucVu nvarchar(255) NOT NULL,
    CoChucNangHLV bit NOT NULL DEFAULT 0,
    NgayVaoLam date NOT NULL,
    PRIMARY KEY (MaNV)
);

CREATE TABLE dbo.HOA_DON (
    MaHD bigint NOT NULL,
    MaHV bigint NOT NULL,
    MaCN bigint NOT NULL,
    MaNVLap bigint NOT NULL,
    NgayLap datetimeoffset(0) NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    TrangThaiHD nvarchar(255) NOT NULL,
    GiamGia numeric(16,2) NOT NULL DEFAULT 0 CHECK (GiamGia >= 0),
    ThanhToanLuc datetimeoffset(0) NULL,
    PRIMARY KEY (MaHD),
    FOREIGN KEY (MaHV) REFERENCES dbo.HOI_VIEN (MaHV),
    FOREIGN KEY (MaCN) REFERENCES dbo.CHI_NHANH (MaCN),
    FOREIGN KEY (MaNVLap) REFERENCES dbo.NHAN_VIEN (MaNV),
    CHECK (TrangThaiHD IN ('CHO_THANH_TOAN', 'DA_THANH_TOAN', 'DA_HUY')),
    CHECK ((TrangThaiHD = 'DA_THANH_TOAN' AND ThanhToanLuc IS NOT NULL)
        OR (TrangThaiHD <> 'DA_THANH_TOAN' AND ThanhToanLuc IS NULL)),
    CHECK (ThanhToanLuc >= NgayLap)
);

CREATE TABLE dbo.GIAO_DICH_THANH_TOAN (
    MaGD bigint NOT NULL,
    MaHD bigint NOT NULL,
    HinhThuc nvarchar(60) NOT NULL,
    TrangThaiGD nvarchar(255) NOT NULL,
    SoTien numeric(16,2) NOT NULL CHECK (SoTien > 0),
    MaThamChieu nvarchar(255) NULL,
    PRIMARY KEY (MaGD),
    FOREIGN KEY (MaHD) REFERENCES dbo.HOA_DON (MaHD),
    CHECK (TrangThaiGD IN ('CHO_XU_LY', 'THANH_CONG', 'THAT_BAI'))
);

CREATE TABLE dbo.CHI_TIET_HOA_DON (
    MaHD bigint NOT NULL,
    SoDong integer NOT NULL CHECK (SoDong > 0),
    MaGoi bigint NULL,
    MaSP bigint NULL,
    SoLuong integer NOT NULL CHECK (SoLuong > 0),
    DonGia numeric(16,2) NOT NULL CHECK (DonGia >= 0),
    GiamGiaPB numeric(16,2) NOT NULL DEFAULT 0 CHECK (GiamGiaPB >= 0),
    PRIMARY KEY (MaHD, SoDong),
    FOREIGN KEY (MaHD) REFERENCES dbo.HOA_DON (MaHD),
    FOREIGN KEY (MaGoi) REFERENCES dbo.GOI_DICH_VU (MaGoi),
    FOREIGN KEY (MaSP) REFERENCES dbo.SAN_PHAM (MaSP),
    CHECK ((MaGoi IS NULL AND MaSP IS NOT NULL)
        OR (MaGoi IS NOT NULL AND MaSP IS NULL)),
    CHECK (GiamGiaPB <= SoLuong * DonGia)
);

CREATE TABLE dbo.GOI_DA_MUA (
    MaGoiMua bigint NOT NULL,
    MaHD bigint NOT NULL,
    SoDong integer NOT NULL,
    BatDauHL date NOT NULL,
    HetHL date NOT NULL,
    SoLuotMua integer NULL CHECK (SoLuotMua > 0),
    PRIMARY KEY (MaGoiMua),
    FOREIGN KEY (MaHD,SoDong) REFERENCES dbo.CHI_TIET_HOA_DON (MaHD,SoDong),
    CHECK (HetHL >= BatDauHL)
);

CREATE TABLE dbo.SU_DUNG_DICH_VU (
    MaSuDung bigint NOT NULL,
    MaGoiMua bigint NOT NULL,
    MaCN bigint NOT NULL,
    ThoiDiem datetimeoffset(0) NOT NULL,
    SoLuotTru integer NOT NULL CHECK (SoLuotTru >= 0),
    PRIMARY KEY (MaSuDung),
    FOREIGN KEY (MaGoiMua) REFERENCES dbo.GOI_DA_MUA (MaGoiMua),
    FOREIGN KEY (MaCN) REFERENCES dbo.CHI_NHANH (MaCN)
);

CREATE TABLE dbo.LICH_PT (
    MaLichPT bigint NOT NULL,
    MaGoiMua bigint NOT NULL,
    MaNVHLV bigint NOT NULL,
    MaCNDienRa bigint NOT NULL,
    BatDau datetimeoffset(0) NOT NULL,
    KetThuc datetimeoffset(0) NOT NULL,
    TrangThaiPT nvarchar(255) NOT NULL,
    PRIMARY KEY (MaLichPT),
    FOREIGN KEY (MaGoiMua) REFERENCES dbo.GOI_DA_MUA (MaGoiMua),
    FOREIGN KEY (MaNVHLV) REFERENCES dbo.NHAN_VIEN (MaNV),
    FOREIGN KEY (MaCNDienRa) REFERENCES dbo.CHI_NHANH (MaCN),
    CHECK (KetThuc > BatDau),
    CHECK (TrangThaiPT IN ('DA_DAT', 'HOAN_THANH', 'DA_HUY'))
);

CREATE TABLE dbo.LUOT_CHECK_IN (
    MaCheckIn bigint NOT NULL,
    MaHV bigint NOT NULL,
    MaCN bigint NOT NULL,
    GioVao datetimeoffset(0) NOT NULL,
    GioRa datetimeoffset(0) NULL,
    ThietBi nvarchar(255) NULL,
    PRIMARY KEY (MaCheckIn),
    FOREIGN KEY (MaHV) REFERENCES dbo.HOI_VIEN (MaHV),
    FOREIGN KEY (MaCN) REFERENCES dbo.CHI_NHANH (MaCN),
    CHECK (GioRa >= GioVao)
);

CREATE TABLE dbo.CHECK_IN_TU_DO (
    MaCheckIn bigint NOT NULL,
    MaGoiMua bigint NOT NULL,
    PRIMARY KEY (MaCheckIn),
    FOREIGN KEY (MaCheckIn) REFERENCES dbo.LUOT_CHECK_IN (MaCheckIn),
    FOREIGN KEY (MaGoiMua) REFERENCES dbo.GOI_DA_MUA (MaGoiMua)
);

CREATE TABLE dbo.CHECK_IN_PT (
    MaCheckIn bigint NOT NULL,
    MaLichPT bigint NOT NULL,
    PRIMARY KEY (MaCheckIn),
    FOREIGN KEY (MaCheckIn) REFERENCES dbo.LUOT_CHECK_IN (MaCheckIn),
    FOREIGN KEY (MaLichPT) REFERENCES dbo.LICH_PT (MaLichPT)
);

CREATE TABLE dbo.NHAT_KY_SUA_CHECK_IN (
    MaCheckIn bigint NOT NULL,
    LanSua integer NOT NULL CHECK (LanSua > 0),
    MaNVSua bigint NOT NULL,
    SuaLuc datetimeoffset(0) NOT NULL,
    LyDo nvarchar(max) NOT NULL,
    PRIMARY KEY (MaCheckIn, LanSua),
    FOREIGN KEY (MaCheckIn) REFERENCES dbo.LUOT_CHECK_IN (MaCheckIn),
    FOREIGN KEY (MaNVSua) REFERENCES dbo.NHAN_VIEN (MaNV)
);

CREATE TABLE dbo.DANH_GIA_PT (
    MaLichPT bigint NOT NULL,
    SoSao integer NOT NULL,
    NhanXet nvarchar(max) NULL,
    ThoiDiemDG datetimeoffset(0) NOT NULL,
    PRIMARY KEY (MaLichPT),
    FOREIGN KEY (MaLichPT) REFERENCES dbo.LICH_PT (MaLichPT),
    CHECK (SoSao BETWEEN 1 AND 5)
);

CREATE TABLE dbo.GIAO_DICH_DIEM (
    MaHD bigint NOT NULL,
    SoDiemCong integer NOT NULL CHECK (SoDiemCong >= 0),
    ThoiDiemGhiNhan datetimeoffset(0) NOT NULL,
    PRIMARY KEY (MaHD),
    FOREIGN KEY (MaHD) REFERENCES dbo.HOA_DON (MaHD)
);

CREATE TABLE dbo.NV_CHINH_SACH_HOA_HONG (
    MaCN bigint NOT NULL,
    HieuLucTu date NOT NULL,
    MucTienMoiBuoi numeric(16,2) NOT NULL CHECK (MucTienMoiBuoi >= 0),
    HieuLucDen date NULL,
    PRIMARY KEY (MaCN, HieuLucTu),
    FOREIGN KEY (MaCN) REFERENCES dbo.CHI_NHANH (MaCN),
    CHECK (HieuLucDen IS NULL OR HieuLucDen >= HieuLucTu)
);

CREATE TABLE dbo.LICH_SU_LUONG (
    MaNV bigint NOT NULL,
    HieuLucTu date NOT NULL,
    LuongCoBan numeric(16,2) NOT NULL CHECK (LuongCoBan >= 0),
    HieuLucDen date NULL,
    PRIMARY KEY (MaNV, HieuLucTu),
    FOREIGN KEY (MaNV) REFERENCES dbo.NHAN_VIEN (MaNV),
    CHECK (HieuLucDen IS NULL OR HieuLucDen >= HieuLucTu)
);

CREATE TABLE dbo.LICH_SU_CONG_TAC (
    MaNV bigint NOT NULL,
    BatDau date NOT NULL,
    MaCN bigint NOT NULL,
    KetThuc date NULL,
    PRIMARY KEY (MaNV, BatDau),
    FOREIGN KEY (MaNV) REFERENCES dbo.NHAN_VIEN (MaNV),
    FOREIGN KEY (MaCN) REFERENCES dbo.CHI_NHANH (MaCN),
    CHECK (KetThuc >= BatDau)
);

CREATE UNIQUE INDEX UX_ThanhToan_HinhThuc_ThamChieu
    ON dbo.GIAO_DICH_THANH_TOAN (HinhThuc, MaThamChieu)
    WHERE MaThamChieu IS NOT NULL;

COMMIT;
